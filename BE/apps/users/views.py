from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.models import User
from rest_framework import serializers
from django.contrib.auth import authenticate
from django.db import connection
import uuid


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
    username = request.data.get('username')
    password = request.data.get('password')
    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT user_id, username, display_picture, favourite_products, phone FROM users WHERE username = %s AND password = %s",
            [username, password]
        )
        row = cursor.fetchone()
    if row:
        data = {
            "user_id": row[0],
            "username": row[1],
            "display_picture": row[2],
            "favourite_products": row[3],
            "phone": row[4]
        }
        return api_response(
            data=data,
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
    with connection.cursor() as cursor:
        cursor.execute("SELECT user_id, username, display_picture, favourite_products, phone FROM users")
        rows = cursor.fetchall()
    data = [
        {
            "user_id": row[0],
            "username": row[1],
            "display_picture": row[2],
            "favourite_products": row[3],
            "phone": row[4]
        }
        for row in rows
    ]
    return Response(data, status=status.HTTP_200_OK)

# Đăng ký tài khoản (thực tế)
@api_view(['POST'])
def signup(request):
    try:
        username = request.data.get('username')
        password = request.data.get('password')
        display_picture = request.data.get('display_picture', '')
        favourite_products = request.data.get('favourite_products', '')
        phone = request.data.get('phone', '')
        user_id = request.data.get('user_id')
        if not user_id:
            user_id = f"u{uuid.uuid4().hex[:6]}"

        # Kiểm tra username đã tồn tại chưa
        with connection.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) FROM users WHERE username = %s", [username])
            if cursor.fetchone()[0] > 0:
                return api_response(data={"is_success": False}, message="Username already exists", code=400, status=400)

        # Insert user mới
        with connection.cursor() as cursor:
            cursor.execute(
                "INSERT INTO users (user_id, username, password, display_picture, favourite_products, phone) VALUES (%s, %s, %s, %s, %s, %s)",
                [user_id, username, password, display_picture, favourite_products, phone]
            )

        return api_response(data={"is_success": True}, message="Signup success", code=201, status=201)
    except Exception as e:
        return api_response(data=None, message="Signup failed", code=500, status=500, errMessage=str(e))



@api_view(['GET'])
def cart(request):
    user_id = request.query_params.get('user_id')
    if not user_id:
        return api_response(data=None, message="Missing user_id", code=400, status=400)
    with connection.cursor() as cursor:
        cursor.execute("SELECT user_id FROM cart WHERE user_id = %s", [user_id])
        rows = cursor.fetchall()
    data = [
        {
            "user_id": row[0]
        }
        for row in rows
    ]
    return api_response(data=data, message="Get cart success", code=200, status=200)

@api_view(['DELETE'])
def remove_from_cart(request, productid):
    user_id = request.query_params.get('user_id')
    if not user_id:
        return api_response(data=None, message="Missing user_id", code=400, status=400)
    with connection.cursor() as cursor:
        cursor.execute(
            "DELETE FROM cartitems WHERE cart_id = %s AND product_id = %s RETURNING cart_id, product_id",
            [user_id, productid]
        )
        row = cursor.fetchone()
    if not row:
        return api_response(data=None, message="Product not found in cart", code=404, status=404)
    return api_response(
        data={"user_id": row[0], "product_id": row[1]},
        message="Remove from cart success",
        code=200,
        status=200
    )
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