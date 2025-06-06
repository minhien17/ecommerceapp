from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.models import User
from rest_framework import serializers
from django.contrib.auth import authenticate

def api_response(data=None, message="", code=200, status=200, errMessage=""):
    return Response({
        "message": message,
        "code": code,
        "data": data,
        "status": status,
        "errMessage": errMessage
    }, status=status)

# User Serializer
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email']

# API login (thực tế)
@api_view(['POST'])
def login(request):
    username = request.data.get('email')
    password = request.data.get('password')
    user = authenticate(username=username, password=password)
    if user is not None:
        serializer = UserSerializer(user)
        return api_response(
            data=serializer.data,
            message="Login success",
            code=200,
            status=200
        )
    return api_response(
        data=None,
        message="Wrong password or username",
        code=401,
        status=401,
        errMessage="INVALID_CREDENTIALS"
    )

# Lấy danh sách user từ DB
@api_view(['GET'])
def get_users(request):
    users = User.objects.all()
    serializer = UserSerializer(users, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)

# Đăng ký tài khoản (thực tế)
@api_view(['POST'])
def signup(request):
    username = request.data.get('username')
    email = request.data.get('email')
    password = request.data.get('password')
    if User.objects.filter(username=username).exists() or User.objects.filter(email=email).exists():
        return api_response(data={"is_success": False}, message="Username or email already exists", code=400, status=400)
    user = User.objects.create_user(username=username, email=email, password=password)
    serializer = UserSerializer(user)
    return api_response(data={"is_success": True, "user": serializer.data}, message="Signup success", code=201, status=201)

# Giỏ hàng: TODO - cần model thực tế, tạm thời giữ nguyên fake
FAKE_CART = [
    {
        "product_id": "1",
        "quantity": 2,
        "product": {
            "images": "https://example.com/image1.jpg",
            "discount_price": 9.0,
            "title": "Áo thun nam"
        }
    }
]

@api_view(['GET', 'POST'])
def cart(request):
    if request.method == 'GET':
        return api_response(data=FAKE_CART, message="Get cart success", code=200, status=200)
    elif request.method == 'POST':
        product_id = request.data.get('product_id')
        for item in FAKE_CART:
            if item['product_id'] == product_id:
                return api_response(data={"success": False}, message="Product already in cart", code=400, status=400)
        FAKE_CART.append({
            "product_id": product_id,
            "quantity": request.data.get('quantity', 1),
            "product": {
                "images": request.data.get('images', ''),
                "discount_price": request.data.get('discount_price', 0),
                "title": request.data.get('title', '')
            }
        })
        return api_response(data={"success": True}, message="Add to cart success", code=200, status=200)

@api_view(['DELETE'])
def remove_from_cart(request, productid):
    found = False
    for item in FAKE_CART:
        if item['product_id'] == productid:
            FAKE_CART.remove(item)
            found = True
            break
    if not found:
        return api_response(data=FAKE_CART, message="Product not found in cart", code=404, status=404)
    return api_response(data=FAKE_CART, message="Remove from cart success", code=200, status=200)

# Cập nhật thông tin cá nhân (thực tế)
@api_view(['PATCH'])
def update_user(request):
    user = request.user
    if not user.is_authenticated:
        return api_response(data={"success": False}, message="Authentication required", code=401, status=401)
    username = request.data.get("username")
    email = request.data.get("email")
    if username:
        user.username = username
    if email:
        user.email = email
    user.save()
    serializer = UserSerializer(user)
    return api_response(data={"success": True, "user": serializer.data}, message="Update user success", code=200, status=200)