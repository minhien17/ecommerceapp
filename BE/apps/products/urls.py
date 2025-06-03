from django.urls import path

from apps.products.views import getProduct

urlpatterns = [
    path('', getProduct, name='products'),
]