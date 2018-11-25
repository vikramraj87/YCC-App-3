#  Data Organization

### Image Descriptor table for searching image by image
1. ImageID
2. ??? Features

### Image
1. ImageID
2. FileName 

### Jewel
1. JewelID
2. DealerID
3. ImportedOn
4. 

### Jewel-Images
1. JewelID
2. ImageID


### Dealer
1. DealerID
2. Mobile

### Bills
1. BillD
2. DealerID
3. Date
4. PaymentStatus
5. FileName

### Courier
1. CourierID
2. Name
3. TrackingPage

- Ability to open the tracking page directly from the App
- Use API if available to provide tracking details in the app

### CourierReceipt
1. ReceiptID
2. FileName
3. TrackingID


### Order
1. OrderID
2. JewelID
3. DealerPrice
4. Profit
5. ProposedShipping
6. ActualShipping



- A jewel can have multiple images
