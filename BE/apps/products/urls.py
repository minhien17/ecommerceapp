from django.urls import path
from .views import product_detail, product_list, review, upload_product, my_products, delete_product, review_detail

urlpatterns = [
    path('upload', upload_product, name='upload_product'),  # POST /api/products/upload
    path('myproduct', my_products, name='my_products'),     # GET /api/products/myproduct
    path('review/<str:productid>', review, name='review'),  # GET & POST /api/products/review/<productid>
    path('<str:productid>', product_detail, name='product_detail'),  # GET & POST /api/products/<productid>
    path('review/<str:productid>/detail', review_detail, name='review_detail'),
    path('delete/<str:productid>', delete_product, name='delete_product'),  # DELETE /api/products/delete/<productid>
    path('', product_list, name='product_list'),  # GET /api/products
    # path('review/<str:productid>/detail', review_detail, name='review_detail'),
]