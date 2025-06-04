from rest_framework.response import Response
from rest_framework.decorators import api_view

def api_response(data=None, message="", code=200, status=200, errMessage=""):
    return Response({
        "message": message,
        "code": code,
        "data": data,
        "status": status,
        "errMessage": errMessage
    }, status=status
    ,content_type='application/json; charset=utf-8' #truyền được ký tự tiếng việt
    )

#get product
@api_view(['GET'])
def product_detail(request, productid):
    # Fake data
    product = {
        "product_id": productid,
        "description": "Áo thun nam chất liệu cotton thoáng mát",
        "discount_price": 9.0,
        "highlights": "Thoáng mát, trẻ trung",
        "images": [
            "https://biznonofinzxzzkoefmp.supabase.co/storage/v1/object/public/ecommerce/user/display_picture/sfDVgu50oyQt4iHk9pK0RZ0ikwh2"
        ],
        "original_price": 12.0,
        "owner": "user123",
        "product_type": "clothing",
        "rating": 4.5,
        "search_tags": ["áo thun", "nam", "cotton"],
        "seller": "user123",
        "title": "Áo thun nam",
        "variant": "Màu trắng, Size L"
    }
    return api_response(data=product, message="Get product detail success", code=200, status=200)

#get list product
@api_view(['GET'])
def product_list(request):
    # Fake data
    products = [
        {
            "product_id": "1",
            "description": "Áo thun nam chất liệu cotton thoáng mát",
            "discount_price": 9.0,
            "highlights": "Thoáng mát, trẻ trung",
            "images": [
                "https://biznonofinzxzzkoefmp.supabase.co/storage/v1/object/public/ecommerce/user/display_picture/sfDVgu50oyQt4iHk9pK0RZ0ikwh2",
                "https://biznonofinzxzzkoefmp.supabase.co/storage/v1/object/public/ecommerce/user/display_picture/sfDVgu50oyQt4iHk9pK0RZ0ikwh2"
            ],
            "original_price": 12.0,
            "owner": "user123",
            "product_type": "clothing",
            "rating": 4.5,
            "search_tags": ["áo thun", "nam", "cotton"],
            "seller": "user123",
            "title": "Áo thun nam",
            "variant": "Màu trắng, Size L"
        },
        {
            "product_id": "2",
            "description": "Quần jeans nữ co giãn",
            "discount_price": 15.0,
            "highlights": "Co giãn, thời trang",
            "images": [
                "https://biznonofinzxzzkoefmp.supabase.co/storage/v1/object/public/ecommerce/user/display_picture/sfDVgu50oyQt4iHk9pK0RZ0ikwh2"
            ],
            "original_price": 20.0,
            "owner": "user456",
            "product_type": "clothing",
            "rating": 4.0,
            "search_tags": ["quần jeans", "nữ", "co giãn"],
            "seller": "user456",
            "title": "Quần jeans nữ",
            "variant": "Màu xanh, Size M"
        }
    ]
    return api_response(data=products, message="Get product list success", code=200, status=200)

#review
@api_view(['GET', 'POST'])
def review(request, productid):
    if request.method == 'GET':
        # Fake data
        reviews = [
            {
                "rating": 5,
                "review": "Sản phẩm rất tốt!",
                "review_uid": "user123",
                "review_name": "Minh Hiển"
            },
            {
                "rating": 4,
                "review": "Chất lượng ổn, giao hàng nhanh.",
                "review_uid": "user456",
                "review_name": "Mai Lan"
            }
        ]
        return api_response(data=reviews, message="Get reviews success", code=200, status=200)
    elif request.method == 'POST':
        rating = request.data.get("rating")
        review_text = request.data.get("review")
        # Fake: luôn trả về thành công
        return api_response(data={"success": True}, message="Add review success", code=200, status=200)

