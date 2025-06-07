from django.urls import path
from .views import login, get_users, signup, cart, remove_from_cart, update_user, change_password
from .views import add_to_cart, increase_cart_item, decrease_cart_item
urlpatterns = [
    path('login', login, name='login'),
    path('getuser', get_users, name='getuser'),
    path('signup', signup, name='signup'),
    path('cart', cart, name='cart'),
    path('cart/<str:productid>', add_to_cart, name='add_to_cart'),  # POST
    path('cart/<str:productid>/increase', increase_cart_item, name='increase_cart_item'),  # POST
    path('cart/<str:productid>/decrease', decrease_cart_item, name='decrease_cart_item'),  # POST
    path('cart/<str:productid>', remove_from_cart, name='remove_from_cart'),
    path('update', update_user, name='update_user'),
    path('changepw', change_password, name='change_password'),
    
]
