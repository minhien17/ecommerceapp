from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.db.models import Q
from .models import Product, Review
from django.db import connection
from rest_framework import status
import uuid

def api_response(data=None, message="", code=200, status=200, errMessage=""):
    return Response({
        "message": message,
        "code": code,
        "data": data,
        "status": status,
        "errMessage": errMessage
    }, status=status, content_type='application/json; charset=utf-8')

# Product detail
@api_view(['GET', 'POST'])
def product_detail(request, productid):
    try:
        product = Product.objects.get(product_id=productid)
    except Product.DoesNotExist:
        return api_response(data=None, message="Product not found", code=404, status=404)

    if request.method == 'GET':
        images = product.image.split(',') if product.image else None
        search_tags = product.search_tags.split(',') if product.search_tags else None
        data = {
            "product_id": product.product_id or None,
            "description": product.description or None,
            "discount_price": float(product.original_price) if product.original_price and product.original_price.replace('.', '', 1).isdigit() else None,
            "highlights": product.highlight or None,
            "images": images,
            "original_price": float(product.original_price) if product.original_price and product.original_price.replace('.', '', 1).isdigit() else None,
            "owner": product.owner or None,
            "product_type": product.product_type or None,
            "rating": float(product.rating) if product.rating is not None else None,
            "search_tags": search_tags,
            "seller": product.seller or None,
            "title": product.title or None,
            "variant": product.variant or None
        }
        return api_response(data=data, message="Get product detail success")

    elif request.method == 'POST':
        # Cập nhật các trường nếu có trong request.data
        for field in ["description", "highlight", "original_price", "product_type", "rating", "search_tags", "seller", "title", "variant", "owner"]:
            if field in request.data:
                setattr(product, field, request.data[field])
        # Xử lý images và search_tags nếu là mảng
        if 'images' in request.data:
            product.image = ','.join(request.data['images'])
        if 'search_tags' in request.data:
            product.search_tags = ','.join(request.data['search_tags'])
        product.save()
        return api_response(message="Update product success", data={"product_id": product.product_id})
    
# Product list, filter, search
@api_view(['GET'])
def product_list(request):
    category = request.GET.get('category')
    query = request.GET.get('query')
    qs = Product.objects.all()
    if category:
        qs = qs.filter(product_type=category)
    if query:
        qs = qs.filter(
            Q(title__icontains=query) |
            Q(description__icontains=query) |
            Q(highlight__icontains=query) |
            Q(variant__icontains=query) |
            Q(seller__icontains=query) |
            Q(search_tags__icontains=query)
        )
    data = []
    for product in qs:
        images = product.image.split(',') if product.image else []
        search_tags = product.search_tags.split(',') if product.search_tags else []
        data.append({
            "product_id": product.product_id or None,
            "description": product.description or None,
            "discount_price": float(product.original_price) if product.original_price and product.original_price.replace('.', '', 1).isdigit() else None,
            "highlights": product.highlight or None,
            "images": images,
            "original_price": float(product.original_price) if product.original_price and product.original_price.replace('.', '', 1).isdigit() else None,
            "owner": product.owner or None,
            "product_type": product.product_type or None,
            "rating": float(product.rating) if product.rating is not None else None,
            "search_tags": search_tags,
            "seller": product.seller or None,
            "title": product.title or None,
            "variant": product.variant or None
        })
    return api_response(data=data, message="Get product list success")

#upload product
@api_view(['POST'])
def upload_product(request):
    data = request.data
    # Tạo product_id tự động
    product_id = f"p{uuid.uuid4().hex[:8]}"
    product = Product.objects.create(
        product_id=product_id,
        description=data.get("description"),
        highlight=data.get("highlights"),
        image=','.join(data.get("images")) if data.get("images") else None,
        original_price=str(data.get("original_price")) if data.get("original_price") else None,
        product_type=data.get("product_type"),
        rating=data.get("rating") or 0,
        search_tags=','.join(data.get("search_tags")) if data.get("search_tags") else None,
        seller=data.get("seller"),
        title=data.get("title"),
        variant=data.get("variant"),
        owner=data.get("owner"),
    )
    return api_response(message="Upload product success", data={"product_id": product.product_id})

#get my product
@api_view(['GET'])
def my_products(request):
    token = request.headers.get('Authorization') or request.headers.get('token')
    if not token:
        return api_response(data=None, message="Missing token", code=400, status=400)
    if token.startswith("Bearer "):
        token = token.split(" ")[1]
    products = Product.objects.filter(owner=token)
    data = []
    for product in products:
        images = product.image.split(',') if product.image else None
        search_tags = product.search_tags.split(',') if product.search_tags else None
        data.append({
            "product_id": product.product_id or None,
            "description": product.description or None,
            "discount_price": float(product.original_price) if product.original_price and product.original_price.replace('.', '', 1).isdigit() else None,
            "highlights": product.highlight or None,
            "images": images,
            "original_price": float(product.original_price) if product.original_price and product.original_price.replace('.', '', 1).isdigit() else None,
            "owner": product.owner or None,
            "product_type": product.product_type or None,
            "rating": float(product.rating) if product.rating is not None else None,
            "search_tags": search_tags,
            "seller": product.seller or None,
            "title": product.title or None,
            "variant": product.variant or None
        })
    return api_response(data=data, message="Get my products success")

#delete product
@api_view(['DELETE'])
def delete_product(request, productid):
    try:
        product = Product.objects.get(product_id=productid)
        product.delete()
        return Response({"success": True, "message": "Product deleted"})
    except Product.DoesNotExist:
        return Response({"success": False, "message": "Product not found"}, status=404)

# Review GET & POST
from .models import Review
from apps.users.models import User

@api_view(['GET', 'POST'])
def review(request, productid):
    if request.method == 'GET':
        reviews = Review.objects.filter(product__product_id=productid)
        data = []
        for r in reviews:
            try:
                user = User.objects.get(user_id=r.reviewer_id)
                reviewer_name = user.username
            except User.DoesNotExist:
                reviewer_name = None
            data.append({
                "rating": r.rating if r.rating is not None else None,
                "review": r.review or None,
                "review_uid": r.reviewer_id or None,
                "review_name": reviewer_name
            })
        return api_response(data=data, message="Get reviews success")
    elif request.method == 'POST':
        rating = request.data.get("rating")
        review_text = request.data.get("review")
        reviewer_id = request.headers.get('token') or request.data.get('reviewer_id')
        if not (rating and review_text and reviewer_id):
            return api_response(data=None, message="Missing data", code=400, status=400)
        Review.objects.create(
            review_id=f"{productid}_{reviewer_id}",
            product_id=productid,
            rating=rating,
            review=review_text,
            reviewer_id=reviewer_id
        )
        return api_response(data={"success": True}, message="Add review success")