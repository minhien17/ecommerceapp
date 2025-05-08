from django.urls import path, include

urlpatterns = [
    # Các endpoints của ứng dụng sẽ được thêm ở đây
    path('auth/', include('apps.users.urls')),
    path('products/', include('apps.products.urls')),
    path('cart/', include('apps.cart.urls')),
    path('orders/', include('apps.orders.urls')),
    path('favorites/', include('apps.favorites.urls')),
    path('addresses/', include('apps.addresses.urls')),
    path('payments/', include('apps.payments.urls')),
    path('returns/', include('apps.returns.urls')),
    path('hello/', include('apps.hello.urls')),
]