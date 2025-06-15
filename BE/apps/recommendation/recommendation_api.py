from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.db.models import Q
from apps.products.models import Product, Review
from apps.users.models import User
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
import pandas as pd
import traceback

def api_response(data=None, message="", code=200, status=200, errMessage=""):
    return Response({
        "message": message,
        "code": code,
        "data": data,
        "status": status,
        "errMessage": errMessage
    }, status=status, content_type='application/json; charset=utf-8')

def get_user_item_matrix(product_ids_order=None):
    """Xây dựng ma trận tương tác user-item từ bảng review."""
    reviews = Review.objects.all().values('reviewer_id', 'product_id', 'rating')
    df = pd.DataFrame(reviews)

    # Tạo ma trận user-item
    user_item_matrix = df.pivot_table(index='reviewer_id', columns='product_id', values='rating', fill_value=0)

    # Nếu có thứ tự product_id từ ma trận tf-idf thì reindex để đồng bộ
    if product_ids_order:
        user_item_matrix = user_item_matrix.reindex(columns=product_ids_order, fill_value=0)

    print("User-Item Matrix:")
    print(user_item_matrix)
    return user_item_matrix

def get_product_features():
    """Lấy đặc trưng sản phẩm từ bảng Product."""
    products = Product.objects.all()
    product_data = []
    for product in products:
        product_data.append({
            'product_id': product.product_id,
            'product_type': product.product_type or '',
            'variant': product.variant or '',
            'rating': product.rating or 0
        })
    product_df = pd.DataFrame(product_data)
    print("Product features dataframe:")
    print(product_df)
    return product_df

def calculate_item_similarity():
    """Tính ma trận tương đồng giữa các sản phẩm dựa trên product_type và variant."""
    product_features = get_product_features()

    # Tạo đặc trưng kết hợp
    product_features['combined_features'] = product_features['product_type'] + ' ' + product_features['variant']
    tfidf_matrix = pd.get_dummies(product_features['combined_features'])

    # Tính ma trận tương đồng cosine
    similarity_matrix = cosine_similarity(tfidf_matrix)

    # Lấy danh sách product_ids đúng thứ tự dòng của similarity_matrix
    product_ids = product_features['product_id'].tolist()

    print("Filtered Product IDs:", product_ids)
    return similarity_matrix, product_ids

def recommend_products_based_on_ratings(user_id, user_item_matrix, item_similarity_matrix, product_ids, top_n=10):
    """Gợi ý sản phẩm dựa trên ma trận tương đồng sản phẩm và đánh giá của user."""
    if user_id not in user_item_matrix.index:
        print(f"User {user_id} not found in User-Item Matrix.")
        return []

    # Lấy đánh giá của user theo đúng thứ tự product_ids
    user_ratings_series = user_item_matrix.loc[user_id]
    user_ratings = user_ratings_series.values  # numpy array

    # Kiểm tra kích thước ma trận
    if item_similarity_matrix.shape[0] != len(product_ids):
        raise ValueError("Kích thước của ma trận tương đồng không khớp với số lượng sản phẩm.")

    # Tính điểm gợi ý cho tất cả sản phẩm
    scores = item_similarity_matrix.dot(user_ratings) / np.sum(item_similarity_matrix, axis=1)
    scores = pd.Series(scores, index=product_ids)

    # Loại bỏ sản phẩm mà user đã đánh giá
    scores = scores[user_ratings_series == 0]

    # Lấy top N sản phẩm gợi ý
    recommended_product_ids = scores.nlargest(top_n).index.tolist()
    print(f"Recommended products for user {user_id}: {recommended_product_ids}")
    return recommended_product_ids

@api_view(['GET'])
def recommend_products(request):
    try:
        # Lấy danh sách recommended_product_ids
        recommended_product_ids = ['prod045', 'prod002', 'prod003', 'prod005', 'prod006', 'p0ed61020', 'p002', 'prod009', 'prod010', 'prod016']
        print("DEBUG - recommended_product_ids:", recommended_product_ids)

        # Lấy danh sách sản phẩm từ bảng Product
        product_ids = Product.objects.filter(product_id__in=recommended_product_ids).values_list('product_id', flat=True)
        print("DEBUG - product_ids:", product_ids)

        # Sắp xếp sản phẩm theo thứ tự trong recommended_product_ids
        ordered_products = sorted(
            list(product_ids),
            key=lambda x: recommended_product_ids.index(x)  # Sử dụng index từ danh sách recommended_product_ids
        )

        # Lấy thông tin chi tiết sản phẩm
        products = Product.objects.filter(product_id__in=ordered_products)
        # data = [
        #     {
        #         "product_id": product.product_id,
        #         "description": product.description,
        #         "highlight": product.highlight,
        #         "image": product.image.split(',') if product.image else None,
        #         "original_price": float(product.original_price) if product.original_price and product.original_price.replace('.', '', 1).isdigit() else None,
        #         "discount_price": float(product.original_price) if product.original_price and product.original_price.replace('.', '', 1).isdigit() else None,
        #         "product_type": product.product_type,
        #         "rating": product.rating,
        #         "search_tags": product.search_tags.split(',') if product.search_tags else None,
        #         "seller": product.seller,
        #         "title": product.title,
        #         "variant": product.variant,
        #         "owner": product.owner,
        #     }
        #     for product in products
        # ]
        data = []
        for product in products:
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

        return api_response(data=data, message="Recommendation success", code=200, status=200)
    except Exception as e:
        return api_response(data=None, message="An error occurred", code=500, status=500, errMessage=str(e))