from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status, serializers
from .models import User, Cart, CartItem, Product
import uuid

def api_response(data=None, message="", code=200, status=200, errMessage=""):
    return Response({
        "message": message,
        "code": code,
        "data": data,
        "status": status,
        "errMessage": errMessage
    }, status=status)

class UserSerializer(serializers.ModelSerializer):
    favourite_products = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ['user_id', 'username', 'email', 'display_picture', 'favourite_products', 'phone']

    def get_favourite_products(self, obj):
        if obj.favourite_products:
            return [item.strip() for item in obj.favourite_products.split(',') if item.strip()]
        return []


class CartItemSerializer(serializers.ModelSerializer):
    product = serializers.SerializerMethodField()

    class Meta:
        model = CartItem
        fields = ['product', 'item_count']

    def get_product(self, obj):
        return {
            "product_id": obj.product.product_id,
            "description": obj.product.description,
            "highlight": obj.product.highlight,
            "image": obj.product.image,
            "original_price": obj.product.original_price,
            "product_type": obj.product.product_type,
            "rating": obj.product.rating,
        }


@api_view(['POST'])
def login(request):
    email = request.data.get('email')
    password = request.data.get('password')
    try:
        user = User.objects.get(email=email, password=password)
        data = UserSerializer(user).data
        return api_response(data=data, message="Login success", code=200, status=200)
    except User.DoesNotExist:
        return api_response(
            data=None,
            message="Wrong password or email",
            code=401,
            status=401,
            errMessage="INVALID_CREDENTIALS"
        )
@api_view(['GET'])
def get_users(request):
    users = User.objects.all()
    serializer = UserSerializer(users, many=True)
    return api_response(data=serializer.data, message="Get users success", code=200, status=200)

@api_view(['POST'])
def signup(request):
    try:
        email = request.data.get('email')
        password = request.data.get('password')
        username = request.data.get('username', '')
        display_picture = request.data.get('display_picture', '')
        favourite_products = request.data.get('favourite_products', '')
        phone = request.data.get('phone', '')
        user_id = request.data.get('user_id')
        if not user_id:
            user_id = f"u{uuid.uuid4().hex[:6]}"

        if User.objects.filter(email=email).exists():
            return api_response(data={"is_success": False}, message="Email already exists", code=400, status=400)

        user = User.objects.create(
            user_id=user_id,
            username=username,
            password=password,
            email=email,
            display_picture=display_picture,
            favourite_products=favourite_products,
            phone=phone
        )
        return api_response(data={"is_success": True, "user": UserSerializer(user).data}, message="Signup success", code=201, status=201)
    except Exception as e:
        return api_response(data=None, message="Signup failed", code=500, status=500, errMessage=str(e))

@api_view(['GET'])
def cart(request):
    auth_header = request.headers.get("authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        return api_response(data={"success": False}, message="Missing or invalid token", code=401, status=401)

    parts = auth_header.split(" ")
    if len(parts) < 2:
        return api_response(data=None, message="Invalid Authorization header", code=400, status=400)
    user_id = parts[1]
    if not user_id:
        return api_response(data=None, message="Missing user_id", code=400, status=400)
    try:
        cart = Cart.objects.get(user_id=user_id)
        items = CartItem.objects.filter(cart=cart)
        serializer = CartItemSerializer(items, many=True)
        return api_response(data=serializer.data, message="Get cart success", code=200, status=200)
    except Cart.DoesNotExist:
        return api_response(data=[], message="Cart is empty", code=200, status=200)
    except Exception as e:
        return api_response(data=None, message=f"Server error: {str(e)}", code=500, status=500)

@api_view(['DELETE'])
def remove_from_cart(request, productid):
    user_id = request.query_params.get('user_id')
    if not user_id:
        return api_response(data=None, message="Missing user_id", code=400, status=400)
    try:
        cart = Cart.objects.get(user__user_id=user_id)
        cart_item = CartItem.objects.get(cart=cart, product__product_id=productid)
        cart_item.delete()
        return api_response(data={"user_id": user_id, "product_id": productid}, message="Remove from cart success", code=200, status=200)
    except (Cart.DoesNotExist, CartItem.DoesNotExist):
        return api_response(data=None, message="Product not found in cart", code=404, status=404)

@api_view(['POST'])
def update_user(request):
    user_id = request.data.get("user_id")
    if not user_id:
        return api_response(data={"success": False}, message="Missing user_id", code=400, status=400)

    try:
        user = User.objects.get(user_id=user_id)
        name = request.data.get("name")
        picture = request.data.get("picture")
        number = request.data.get("number")
        password = request.data.get("password")

        if name:
            user.username = name
        if picture:
            user.display_picture = picture
        if number:
            user.phone = number
        if password:
            user.password = password

        user.save()
        serializer = UserSerializer(user)
        return api_response(data={"success": True, "user": serializer.data}, message="Update user success", code=200, status=200)
    except User.DoesNotExist:
        return api_response(data={"success": False}, message="User not found", code=404, status=404)
    except Exception as e:
        return api_response(data={"success": False}, message="An error occurred", code=500, status=500, errMessage=str(e))

@api_view(['POST'])
def change_password(request):
    auth_header = request.headers.get("authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        return api_response(data={"success": False}, message="Missing or invalid token", code=401, status=401)

    parts = auth_header.split(" ")
    user_id = parts[1]

    if not user_id:
        return api_response(data={"success": False}, message="Missing user_id", code=400, status=400)

    try:
        user = User.objects.get(user_id=user_id)
        current_password = request.data.get("current_password")
        new_password = request.data.get("new_password")

        if not current_password or not new_password:
            return api_response(data={"success": False}, message="Missing password fields", code=400, status=400)

        # Kiểm tra mật khẩu hiện tại
        if user.password != current_password:
            return api_response(data={"success": False}, message="Current password is incorrect", code=400, status=400)

        # Cập nhật mật khẩu mới
        user.password = new_password
        user.save()

        return api_response(data={"success": True}, message="Password updated successfully", code=200, status=200)
    except User.DoesNotExist:
        return api_response(data={"success": False}, message="User not found", code=404, status=404)
    except Exception as e:
        return api_response(data={"success": False}, message="An error occurred", code=500, status=500, errMessage=str(e))