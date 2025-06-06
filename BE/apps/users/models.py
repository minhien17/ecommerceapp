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