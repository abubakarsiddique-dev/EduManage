# EduManage Transportation & Library System Specification

This specification outlines the technical contracts, domain entities, and distance calculations supporting campus logistics and library operations.

---

## 1. School Transportation Architecture (`SchoolBusRouteModel`)

The school transit module models fleet routes, assigned drivers, and stops sequence.

### Entity Attributes
- `routeNumber`: Human-readable identifier (e.g., `Route-5`).
- `routeName`: Route label (e.g., `North Campus Express`).
- `vehicleRegistration`: Official license plate (e.g., `LEA-2024`).
- `driverName` & `driverPhone`: Contact points for emergency response and parent notifications.
- `stops`: Ordered list of pick-up and drop-off waypoints.
- `capacity`: Maximum seated student allocation.

### Geofencing & Distance (`GeoDistanceHelper`)
- Employs Haversine spherical trigonometric calculation:
  $$\Delta\sigma = 2 \arcsin \left(\sqrt{\sin^2(\frac{\Delta\phi}{2}) + \cos(\phi_1)\cos(\phi_2)\sin^2(\frac{\Delta\lambda}{2})}\right)$$
- `distanceBetweenKm(lat1, lon1, lat2, lon2)`: Returns precision distance in kilometers.
- `isWithinRadius(...)`: Evaluates proximity alerts when bus approaches within 500 meters of a student's stop.

---

## 2. Library Catalog & Circulations (`LibraryBookModel`)

Manages book circulation, availability, and automated fine calculation.

### Circulation Metrics
- `totalCopies`: Physical volume count in inventory.
- `availableCopies`: Unissued copies currently resting on the shelf.
- `issuedCopies`: Calculated as `totalCopies - availableCopies`.
- `calculateFine(daysOverdue)`: Computes progressive penalty fees based on `lateFeePerDay`.
