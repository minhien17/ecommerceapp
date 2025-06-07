from django.db import models

class User(models.Model):
    user_id = models.CharField(max_length=255, primary_key=True)
    username = models.CharField(max_length=255)
    password = models.CharField(max_length=255)
    email = models.CharField(max_length=255, blank=True, null=True)
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
    user_id = models.CharField(max_length=255, primary_key=True)

    class Meta:
        db_table = 'cart'
        managed = False

    def __str__(self):
        return self.user_id

class CartItem(models.Model):
    cart_id = models.CharField(max_length=255, primary_key=True)  # Chính là user_id
    product_id = models.CharField(max_length=255)
    item_count = models.IntegerField(default=1)

    class Meta:
        db_table = 'cartitems'
        managed = False

    def __str__(self):
        return f"{self.cart_id} - {self.product_id}"
    
class Address(models.Model):
    address_id = models.AutoField(primary_key=True)
    address_line_1 = models.CharField(max_length=255)
    address_line_2 = models.CharField(max_length=255, blank=True, null=True)
    state = models.CharField(max_length=255)
    city = models.CharField(max_length=255)
    district = models.CharField(max_length=255)
    describe = models.CharField(max_length=255, blank=True, null=True)
    phone = models.CharField(max_length=255)
    pincode = models.CharField(max_length=255)
    receiver = models.CharField(max_length=255)
    title = models.CharField(max_length=255)
    user_id = models.CharField(max_length=255)

    class Meta:
        db_table = 'addresses'
        managed = False 