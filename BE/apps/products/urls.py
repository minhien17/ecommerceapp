from django.urls import path
from .views import product_detail, product_list, review

from apps.products.views import getProduct

urlpatterns = [
    path('', product_list, name='product_list'),  # GET /api/products
    path('<str:productid>', product_detail, name='product_detail'),  # GET /api/products/<productid>
    path('review/<str:productid>', review, name='review'),  # GET & POST /api/products/review/<productid>
]