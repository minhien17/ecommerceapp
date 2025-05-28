from django.urls import path
from .views import login, get_users

urlpatterns = [
    path('login', login, name='login'),
    path('getuser', get_users, name='getuser')
]
