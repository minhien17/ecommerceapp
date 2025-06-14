from django.urls import path

from .views import add_to_cart, increase_cart_item, decrease_cart_item,address_api
from .views import login, get_users, signup, cart, remove_from_cart, update_user, change_password,favourite, update_address
from .views import add_ordered_product, get_all_ordered_products

urlpatterns = [
    path('login', login, name='login'),
    path('getuser', get_users, name='getuser'),
    path('signup', signup, name='signup'),
    path('cart', cart, name='cart'),
    path('cart/<str:productid>', add_to_cart, name='add_to_cart'),  # POST
    path('cart/<str:productid>/increase', increase_cart_item, name='increase_cart_item'),  # POST
    path('cart/<str:productid>/decrease', decrease_cart_item, name='decrease_cart_item'),  # POST
    path('cart/<str:productid>/remove', remove_from_cart, name='remove_from_cart'),
    path('update', update_user, name='update_user'),
    path('changepw', change_password, name='change_password'),
    
    path('favourite', favourite, name='favourite_get'),  # GET /api/users/favourite
    path('favourite/<str:productid>', favourite, name='favourite_post'),  # POST /api/users/favourite/<productid>
    
    path('address', address_api, name='address_api'),
    
    path('address/<int:addressid>', update_address, name='address_api_update'),
    
    path('ordered_product', add_ordered_product, name='add_ordered_product'),
    path('ordered_products', get_all_ordered_products, name='get_all_ordered_products'),
]
