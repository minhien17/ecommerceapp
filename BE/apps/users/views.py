from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

# API login
@api_view(['POST'])
def login(request):
    try:
        username = request.data.get('email')
        password = request.data.get('password')

        # if not username or not password:
        #     return Response(
        #         {'status': '400', 'message': 'Vui lòng nhập username và password'},
        #         status=status.HTTP_400_BAD_REQUEST
        #     )

        if username == "hienlinh2624@gmail.com" and password == "123456":
            return Response(
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