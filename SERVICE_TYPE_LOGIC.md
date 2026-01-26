# Service Type Display Logic

## Overview
The app displays service categories dynamically based on products added by vendors in Firestore.

## How It Works

### 1. Data Collection
```
┌─────────────────────────────────────────┐
│  Firestore: users collection            │
│  WHERE role = 'vendor'                  │
│  WHERE status = 'approved'              │
│  WHERE isActive = true                  │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│  For each vendor:                       │
│    - Get all products                   │
│    - Extract product.categoryType       │
│    - Add to service types set           │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│  Display unique service types as tiles  │
└─────────────────────────────────────────┘
```

### 2. Key Changes (Latest Update)

**REMOVED:**
- ❌ Vendor-level `serviceType` field (no longer used)
- ❌ Global service type for vendors

**NOW USING:**
- ✅ Product-level `categoryType` field ONLY
- ✅ Vendors can offer multiple service types through different products

### 3. Example Scenario

**Vendor: "ABC Events"**
```json
{
  "businessName": "ABC Events",
  "role": "vendor",
  "status": "approved",
  "products": [
    {
      "name": "Wedding Stage",
      "categoryType": "Decoration",
      "price": "50000"
    },
    {
      "name": "Luxury Car",
      "categoryType": "Vehicle",
      "price": "30000"
    },
    {
      "name": "Photography Package",
      "categoryType": "Photography",
      "price": "40000"
    }
  ]
}
```

**Result:**
This single vendor contributes 3 service types:
- Decoration
- Vehicle  
- Photography

### 4. Service Type Tiles Displayed

When user clicks "Wedding" category, they see tiles for:
- Convention Center (if any vendor has product with categoryType="Convention Center")
- Decoration (if any vendor has product with categoryType="Decoration")
- Food (if any vendor has product with categoryType="Food")
- Vehicle (if any vendor has product with categoryType="Vehicle")
- Photography (if any vendor has product with categoryType="Photography")
- Music/DJ (if any vendor has product with categoryType="Music/DJ")
- Catering (if any vendor has product with categoryType="Catering")

### 5. Why "Decoration" Might Not Show

**Checklist:**
- [ ] Is there at least one vendor with `status = 'approved'`?
- [ ] Does that vendor have `isActive = true`?
- [ ] Does that vendor have at least one product?
- [ ] Does that product have `categoryType = 'Decoration'`?
- [ ] Is the categoryType field not empty/null?

If ANY of these is false, "Decoration" won't appear.

### 6. Debug Output

When navigating to a category, check terminal for:

```
=== COLLECTING SERVICE TYPES ===
Total approved vendors: 3
Vendor: ABC Events
  - Products: 3
  ✓ Added service type: "Decoration" from product "Wedding Stage"
  ✓ Added service type: "Vehicle" from product "Luxury Car"
  ✓ Added service type: "Photography" from product "Photography Package"
Vendor: XYZ Catering
  - Products: 1
  ✓ Added service type: "Food" from product "Buffet Package"
Vendor: Stage Decor
  - Products: 0
  ⚠ Vendor has no products
=== FINAL SERVICE TYPES ===
Total unique types: 4
Types: {Decoration, Vehicle, Photography, Food}
===========================
```

### 7. Image Mapping

Each service type gets an image based on keywords:

| Service Type Contains | Image Assigned |
|----------------------|----------------|
| "convention", "hall", "center" | convention_center_sub.png |
| "decor" | decoration_sub.png |
| "food", "cater" | food_sub.png |
| "car", "vehicle" | luxury_cars_sub.png |
| "photo", "graphy" | photographer_sub.png |
| "music", "dj" | party_thumb.png |
| "wear", "rental" | rental_wears_sub.png |
| (default) | wedding_thumb.png |

### 8. Vendor Product Addition Flow

When a vendor adds a product, they should:
1. Enter product name (e.g., "Wedding Stage")
2. **Select categoryType** from dropdown:
   - Convention Center
   - Decoration
   - Food & Catering
   - Vehicle
   - Photography
   - Music/DJ
   - Rental Wears
3. Enter price, images, etc.

This way, each product is properly categorized and will appear in the correct service type tile.

## Benefits of This Approach

1. **Flexibility**: Vendors can offer multiple service types
2. **Accuracy**: Service types shown match actual available products
3. **Dynamic**: No hardcoded categories, everything from Firestore
4. **Scalable**: Easy to add new service types by just adding products
5. **No Empty Categories**: Only shows types that have actual products

## Implementation Files

- `lib/views/user/category_detail_view.dart` - Service type collection logic
- `lib/services/user_service.dart` - Vendor fetching from Firestore
- `lib/models/vendor_model.dart` - Data model with product parsing
- `lib/providers/user_provider.dart` - State management for vendors
