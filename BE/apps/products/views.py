from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

# API product
@api_view(['GET'])
def getProduct(request): 
    return Response(
        [
            {
                "product_id":"String",
                "description": "string",           
                "discount_price": 9.0,              
                "highlights": "",               
                "images": ["https://biznonofinzxzzkoefmp.supabase.co/storage/v1/object/public/ecommerce/user/display_picture/sfDVgu50oyQt4iHk9pK0RZ0ikwh2"],          
                "original_price": 9.0,             
                "owner": "string",                
                "product_type": "other",          
                "rating": 0.0,                      
                "search_tags": [],                
                "seller": "string",                
                "title": "string",               
                "variant": "string"                   
            }

        ]
    )