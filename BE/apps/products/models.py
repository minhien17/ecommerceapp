from django.db import models
from django.conf import settings
from django.contrib.postgres.fields import ArrayField

class Category(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    parent = models.ForeignKey('self', on_delete=models.SET_NULL, blank=True, null=True, related_name='children')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name
    
    class Meta:
        verbose_name_plural = 'Categories'

class Product(models.Model):
    product_id = models.CharField(max_length=255, primary_key=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    highlight = models.CharField(max_length=255, blank=True, null=True)
    image = models.TextField(blank=True, null=True)
    original_price = models.CharField(max_length=255, blank=True, null=True)
    product_type = models.CharField(max_length=255, blank=True, null=True)
    rating = models.IntegerField(default=0)
    search_tags = models.CharField(max_length=255, blank=True, null=True)
    seller = models.CharField(max_length=255, blank=True, null=True)
    title = models.CharField(max_length=255, blank=True, null=True)
    variant = models.CharField(max_length=255, blank=True, null=True)
    owner = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        db_table = 'products' 
        managed = False      

class ProductImage(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='images')
    image = models.ImageField(upload_to='products/')
    is_primary = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Image for {self.product.name}"
    
class Review(models.Model):
    review_id = models.CharField(max_length=255, primary_key=True)
    rating = models.IntegerField()
    review = models.CharField(max_length=255)
    reviewer_id = models.CharField(max_length=255)
    product = models.ForeignKey(Product, on_delete=models.CASCADE, db_column='product_id', related_name='reviews')

    class Meta:
        db_table = 'reviews'