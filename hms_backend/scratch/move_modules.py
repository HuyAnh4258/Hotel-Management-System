import os
import re
import shutil

ROOT_DIR = r"c:\Users\huyanh\Documents\Projects\hms\hms_backend"
SRC_DIR = os.path.join(ROOT_DIR, "src", "main", "java", "com", "hotel", "hms")

# Mapping of file moves: (source_rel_path, target_rel_path)
moves = [
    # Entities
    ("entity/Booking.java", "modules/booking_management/entity/Booking.java"),
    ("entity/Room.java", "modules/booking_management/entity/Room.java"),
    ("entity/RoomBooking.java", "modules/booking_management/entity/RoomBooking.java"),
    ("entity/RoomType.java", "modules/booking_management/entity/RoomType.java"),
    ("entity/Voucher.java", "modules/booking_management/entity/Voucher.java"),

    # Repositories
    ("repository/BookingRepository.java", "modules/booking_management/repository/BookingRepository.java"),
    ("repository/RoomBookingRepository.java", "modules/booking_management/repository/RoomBookingRepository.java"),
    ("repository/RoomRepository.java", "modules/booking_management/repository/RoomRepository.java"),
    ("repository/RoomTypeRepository.java", "modules/booking_management/repository/RoomTypeRepository.java"),
    ("repository/VoucherRepository.java", "modules/booking_management/repository/VoucherRepository.java"),

    # Service
    ("service/BookingService.java", "modules/booking_management/service/BookingService.java"),

    # DTOs
    ("dto/BookingSummary.java", "modules/booking_management/dto/BookingSummary.java"),
    ("dto/CreateBookingRequest.java", "modules/booking_management/dto/CreateBookingRequest.java"),
    ("dto/HomepageResponse.java", "modules/booking_management/dto/HomepageResponse.java"),
    ("dto/RoomSummary.java", "modules/booking_management/dto/RoomSummary.java"),
    ("dto/RoomTypeSummary.java", "modules/booking_management/dto/RoomTypeSummary.java"),

    # Controller
    ("controller/BookingController.java", "modules/booking_management/controller/BookingController.java")
]

# Map old package pattern to new package pattern
package_updates = {
    "com.hotel.hms.entity": "com.hotel.hms.modules.booking_management.entity",
    "com.hotel.hms.repository": "com.hotel.hms.modules.booking_management.repository",
    "com.hotel.hms.service": "com.hotel.hms.modules.booking_management.service",
    "com.hotel.hms.dto": "com.hotel.hms.modules.booking_management.dto",
    "com.hotel.hms.controller": "com.hotel.hms.modules.booking_management.controller"
}

# Perform physical moves and update their package statement
for src_rel, dest_rel in moves:
    src_path = os.path.join(SRC_DIR, src_rel)
    dest_path = os.path.join(SRC_DIR, dest_rel)

    if not os.path.exists(src_path):
        print(f"Skipping {src_rel} (does not exist)")
        continue

    # Ensure target directory exists
    os.makedirs(os.path.dirname(dest_path), exist_ok=True)
    
    # Read, update package header, write to new location, delete old
    with open(src_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Determine new package name based on destination
    dest_dir = os.path.dirname(dest_rel).replace("/", ".")
    new_package = f"com.hotel.hms.{dest_dir}"
    
    # Replace package header
    content = re.sub(r"^package\s+[\w\.]+;", f"package {new_package};", content, flags=re.MULTILINE)
    
    with open(dest_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    os.remove(src_path)
    print(f"Moved and updated package: {src_rel} -> {dest_rel}")

# Helper to recursively find all java files
def find_all_java_files(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".java"):
                yield os.path.join(root, file)

# Search & Replace all imports in the entire codebase
for java_file in find_all_java_files(SRC_DIR):
    with open(java_file, "r", encoding="utf-8") as f:
        content = f.read()

    original = content
    # Replace imports
    for old_pkg, new_pkg in package_updates.items():
        # Match "import com.hotel.hms.entity.Room;" or "import com.hotel.hms.entity.*;"
        content = content.replace(f"import {old_pkg}.", f"import {new_pkg}.")
    
    if content != original:
        with open(java_file, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"Updated imports in: {os.path.relpath(java_file, SRC_DIR)}")

# Clean up empty directories in root
empty_candidates = ["entity", "repository", "service", "dto", "controller"]
for cand in empty_candidates:
    cand_path = os.path.join(SRC_DIR, cand)
    if os.path.exists(cand_path) and not os.listdir(cand_path):
        os.rmdir(cand_path)
        print(f"Removed empty directory: {cand}")
