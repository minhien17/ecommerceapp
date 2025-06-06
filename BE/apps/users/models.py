from django.db import models

class User(models.Model):
    user_id = models.CharField(max_length=255, primary_key=True)
    username = models.CharField(max_length=255)
    password = models.CharField(max_length=255)
    display_picture = models.CharField(max_length=255, blank=True, null=True)
    favourite_products = models.CharField(max_length=255, blank=True, null=True)
    phone = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        db_table = 'users'
class Product(models.Model):
    product_id = models.CharField(max_length=20, primary_key=True)
    description = models.CharField(max_length=255, blank=True)
    highlight = models.CharField(max_length=255, blank=True)
    image = models.CharField(max_length=255, blank=True)
    original_price = models.CharField(max_length=50, blank=True)
    product_type = models.CharField(max_length=100, blank=True)
    rating = models.IntegerField(default=0)

    def __str__(self):
        return self.product_id

class Cart(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, primary_key=True, db_column='user_id')

    def __str__(self):
        return self.user.user_id

class CartItem(models.Model):
    cart = models.ForeignKey(Cart, on_delete=models.CASCADE, db_column='cart_id', related_name='items')
    product = models.ForeignKey(Product, on_delete=models.CASCADE, db_column='product_id')
    item_count = models.IntegerField(default=1)

    def __str__(self):
        return f"{self.cart.user.user_id} - {self.product.product_id}"