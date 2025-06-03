from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

def api_response(data=None, message="", code=200, status=200, errMessage=""):
    return Response({
        "message": message,
        "code": code,
        "data": data,
        "status": status,
        "errMessage": errMessage
    }, status=status)

# API login
@api_view(['POST'])
def login(request):
    try:
        username = request.data.get('email')
        password = request.data.get('password')

        if username == "hienlinh2624@gmail.com" and password == "123456":
            return api_response( data=
                {
                'userid': 'sfDVgu50oyQt4iHk9pK0RZ0ikwh2',
                'username': 'Minh Hiển',
                'email': 'hienlinh2624@gmail.com',
                'image': 'https://biznonofinzxzzkoefmp.supabase.co/storage/v1/object/public/ecommerce/user/display_picture/sfDVgu50oyQt4iHk9pK0RZ0ikwh2'
                },
                content_type='application/json; charset=utf-8' #truyền được ký tự tiếng việt
            )

        return Response(
            {'status': '401', 'message': 'Wrong password or username'},
            status=status.HTTP_401_UNAUTHORIZED
        )

    except Exception as e:
        return Response(
            {'status': '500', 'message': f'Server Error: {str(e)}'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

@api_view(['GET'])
def get_users(request):
    # Dữ liệu giả lập, có thể thay bằng database thực tế
    users = [
        {'userid': 1, 'username': 'Hiển', 'email': 'hienlinh@example.com', 'image': 'https://example.com/avatar1.png'},
        {'userid': 2, 'username': 'Nam', 'email': 'nam@example.com', 'image': 'https://example.com/avatar2.png'},
        {'userid': 3, 'username': 'Mai', 'email': 'mai@example.com', 'image': 'https://example.com/avatar3.png'},
    ]
    
    return Response(users, status=status.HTTP_200_OK)

#sign up
@api_view(['POST'])
def signup(request):
    username = request.data.get('username')
    email = request.data.get('email')
    password = request.data.get('password')
    # TODO: Thêm kiểm tra và lưu user thực tế
    return api_response(data={"is_success": "true"}, message="Signup success", code=201, status=201)

#cart
@api_view(['GET', 'POST'])
def cart(request):
    if request.method == 'GET':
        # ... code lấy giỏ hàng ...
        cart = [
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
        return api_response(data=cart, message="Get cart success", code=200, status=200)
    elif request.method == 'POST':
        # ... code thêm sản phẩm vào giỏ ...
        return api_response(data={"success": True}, message="Add to cart success", code=200, status=200)

#xoa sp
@api_view(['DELETE'])
def remove_from_cart(request, productid):
    # TODO: Xóa sản phẩm khỏi cart thực tế
    cart = []
    return api_response(data=cart, message="Remove from cart success", code=200, status=200)

#cap nhat thong tin ca nhan
@api_view(['PATCH'])
def update_user(request):
    # TODO: Lấy user từ token, cập nhật thông tin
    if request.data.get("password") == "wrong":
        return api_response(data={"success": False}, message="Invalid password", code=400, status=400, errMessage="INVALID_PASSWORD")
    user = {
        "id": "user_id",
        "picture": request.data.get("picture"),
        "name": request.data.get("name"),
        "number": request.data.get("number")
    }
    return api_response(data={"success": True, "user": user}, message="Update user success", code=200, status=200)
