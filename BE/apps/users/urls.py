from django.urls import path
from .views import login, get_users, signup, cart, remove_from_cart, update_user, change_password

urlpatterns = [
    path('login', login, name='login'),
    path('getuser', get_users, name='getuser'),
    path('signup', signup, name='signup'),
    path('cart', cart, name='cart'),
    path('cart/<str:productid>', remove_from_cart, name='remove_from_cart'),
    path('update', update_user, name='update_user'),
    path('changepw', change_password, name='change_password'),
]
