from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status, serializers
from .models import User, Cart, CartItem, Address,OrderedProduct
from apps.products.models import Product
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

class AddressSerializer(serializers.ModelSerializer):
    class Meta:
        model = Address
        fields = '__all__'

class OrderedProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderedProduct
        fields = ['ordered_product_id', 'order_date', 'product_id', 'user_id']
        
    
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
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        return Response([], status=401)
    user_id = auth_header.split(" ")[1]
    items = CartItem.objects.filter(cart_id=user_id)
    data = [
        {
            "product_id": item.product_id,
            "item_count": item.item_count
        }
        for item in items
    ]
    return Response(data)

@api_view(['POST'])
def add_to_cart(request, productid):
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        return api_response(data=None, message="Missing or invalid token", code=401, status=401)

    user_id = auth_header.split(" ")[1]
    try:
        # KIỂM TRA TRƯỚC
        cart_item = CartItem.objects.filter(cart_id=user_id, product_id=productid).first()
        if cart_item:
            cart_item.item_count += 1
            cart_item.save()
        else:
            CartItem.objects.create(cart_id=user_id, product_id=productid, item_count=1)

        return api_response(data={"success": True}, message="Add to cart success", code=200, status=200)

    except Exception as e:
        return api_response(data=None, message="Add to cart failed", code=500, status=500, errMessage=str(e))

@api_view(['POST'])
def increase_cart_item(request, productid):
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        return api_response(data=None, message="Missing or invalid token", code=401, status=401)
    user_id = auth_header.split(" ")[1]
    try:
        cart_item = CartItem.objects.get(cart_id=user_id, product_id=productid)
        cart_item.item_count += 1
        cart_item.save()
        return api_response(data={"success": True}, message="Increased item count", code=200, status=200)
    except CartItem.DoesNotExist:
        return api_response(data=None, message="Product not found in cart", code=404, status=404)

@api_view(['POST'])
def decrease_cart_item(request, productid):
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        return api_response(data=None, message="Missing or invalid token", code=401, status=401)
    user_id = auth_header.split(" ")[1]
    try:
        cart_item = CartItem.objects.get(cart_id=user_id, product_id=productid)
        if cart_item.item_count > 1:
            cart_item.item_count -= 1
            cart_item.save()
            return api_response(data={"success": True}, message="Decreased item count", code=200, status=200)
        else:
            return api_response(data={"success": False}, message="Item count is already 1", code=200, status=200)
    except CartItem.DoesNotExist:
        return api_response(data=None, message="Product not found in cart", code=404, status=404)

@api_view(['DELETE'])
def remove_from_cart(request, productid):
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        return api_response(data=None, message="Missing or invalid token", code=401, status=401)
    cart_id = auth_header.split(" ")[1]

    if not cart_id:
        return api_response(data=None, message="Missing cart_id", code=400, status=400)
    try:
        cart_item = CartItem.objects.get(cart_id=cart_id, product_id=productid)
        cart_item.delete()
        return api_response(data={"cart_id": cart_id, "product_id": productid}, message="Remove from cart success", code=200, status=200)
    except CartItem.DoesNotExist:
        return api_response(data=None, message="Product not found in cart", code=404, status=404)

@api_view(['POST'])
def update_user(request):
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        return api_response(data=None, message="Missing or invalid token", code=401, status=401)
    user_id = auth_header.split(" ")[1]
    
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
    

#get, post product u like
@api_view(['GET', 'POST'])
def favourite(request, productid=None):
    # Lấy user_id từ header
    token = request.headers.get('token') or request.headers.get('Authorization')
    if not token:
        return Response([], status=401)
    if token.lower().startswith("bearer "):
        user_id = token.split(" ")[1]
    else:
        user_id = token
    try:
        user = User.objects.get(user_id=user_id)
    except User.DoesNotExist:
        return Response([], status=404)

    # GET: trả về list product yêu thích
    if request.method == 'GET':
        fav_ids = [pid.strip() for pid in (user.favourite_products or '').split(',') if pid.strip()]
        products = Product.objects.filter(product_id__in=fav_ids)
        data = []
        for product in products:
            images = product.image.split(',') if product.image else []
            data.append({
                "product_id": product.product_id or None,
                "description": product.description or None,
                "discount_price": float(product.original_price) if product.original_price and product.original_price.replace('.', '', 1).isdigit() else None,
                "highlights": product.highlight or None,
                "images": images,
                "original_price": float(product.original_price) if product.original_price and product.original_price.replace('.', '', 1).isdigit() else None,
                "owner": getattr(product, "owner", None),
                "product_type": product.product_type or None,
                "rating": float(product.rating) if product.rating is not None else None,
                "search_tags": product.search_tags.split(',') if product.search_tags else [],
                "seller": getattr(product, "seller", None),
                "title": product.title or None,
                "variant": product.variant or None
            })
        return Response(data)

    # POST: thêm/xóa product_id khỏi danh sách yêu thích
    if request.method == 'POST':
        if not productid:
            return Response({"status": False, "message": "Missing product_id"}, status=400)
        fav_ids = [pid.strip() for pid in (user.favourite_products or '').split(',') if pid.strip()]
        if productid in fav_ids:
            fav_ids.remove(productid)
        else:
            fav_ids.append(productid)
        user.favourite_products = ','.join(fav_ids)
        user.save()
        return Response({"status": True})
    
# api address
@api_view(['GET', 'POST', 'PUT', 'DELETE'])
def address_api(request):
    # Lấy user_id từ Authorization header
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        return api_response(data=None, message="Missing or invalid token", code=401, status=401)
    user_id = auth_header.split(" ")[1]

    # GET: Lấy danh sách địa chỉ của user
    if request.method == 'GET':
        addresses = Address.objects.filter(user_id=user_id)
        serializer = AddressSerializer(addresses, many=True)
        return api_response(data=serializer.data, message="Get addresses success", code=200, status=200)

    # POST: Thêm địa chỉ mới

    if request.method == 'POST':
        try:
            data = request.data.copy()
            data['user_id'] = user_id
            if not data.get('address_id'):
                return api_response(data=None, message="Missing address_id", code=400, status=400)
            print("DEBUG - Data gửi vào serializer:", data)  # Thêm dòng này để kiểm tra
            if Address.objects.filter(address_id=data['address_id']).exists():
                return api_response(data=None, message="address_id already exists", code=400, status=400)
            serializer = AddressSerializer(data=data)
            if serializer.is_valid():
                serializer.save()
                return api_response(data=serializer.data, message="Add address success", code=201, status=201)
            print("Serializer errors:", serializer.errors)
            return api_response(data=None, message="Invalid data", code=400, status=400, errMessage=serializer.errors)
        except Exception as e:
            print("Exception in address POST:", str(e))
            return api_response(data=None, message="Internal server error", code=500, status=500, errMessage=str(e))


    # PUT: Sửa địa chỉ (cần truyền address_id trong body)
    if request.method == 'PUT':
        address_id = request.data.get('address_id')
        if not address_id:
            return api_response(data=None, message="Missing address_id", code=400, status=400)
        try:
            address = Address.objects.get(address_id=address_id, user_id=user_id)
        except Address.DoesNotExist:
            return api_response(data=None, message="Address not found", code=404, status=404)
        serializer = AddressSerializer(address, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return api_response(data=serializer.data, message="Update address success", code=200, status=200)
        return api_response(data=None, message="Invalid data", code=400, status=400, errMessage=serializer.errors)

    # DELETE: Xóa địa chỉ (cần truyền address_id trong body)
    if request.method == 'DELETE':
        address_id = request.data.get('address_id')
        if not address_id:
            return api_response(data=None, message="Missing address_id", code=400, status=400)
        try:
            address = Address.objects.get(address_id=address_id, user_id=user_id)
            address.delete()
            return api_response(data=None, message="Delete address success", code=200, status=200)
        except Address.DoesNotExist:
            return api_response(data=None, message="Address not found", code=404, status=404)


@api_view(['POST'])
def add_ordered_product(request):
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        return api_response(data=None, message="Missing or invalid token", code=401, status=401)
    user_id = auth_header.split(" ")[1]
    data = request.data.copy()
    data['user_id'] = user_id

    # Tự sinh ordered_product_id tăng dần
    from .models import OrderedProduct
    last = OrderedProduct.objects.order_by('-ordered_product_id').first()
    data['ordered_product_id'] = (last.ordered_product_id + 1) if last else 1

    try:
        serializer = OrderedProductSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return api_response(data=serializer.data, message="Add ordered product success", code=201, status=201)
        return api_response(data=None, message="Invalid data", code=400, status=400, errMessage=serializer.errors)
    except Exception as e:
        return api_response(data=None, message="Internal server error", code=500, status=500, errMessage=str(e))