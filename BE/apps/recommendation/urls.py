from django.urls import path
from .recommendation_api import recommend_products

urlpatterns = [
    path('recommend', recommend_products, name='recommend_products'),
]