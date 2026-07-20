$srcDir = "c:\Users\huyanh\Documents\Projects\hms\hms_backend\src\main\java\com\hotel\hms"

# Mapping of file moves
$moves = @(
    @("entity/Booking.java", "modules/booking_management/entity/Booking.java"),
    @("entity/Room.java", "modules/booking_management/entity/Room.java"),
    @("entity/RoomBooking.java", "modules/booking_management/entity/RoomBooking.java"),
    @("entity/RoomType.java", "modules/booking_management/entity/RoomType.java"),
    @("entity/Voucher.java", "modules/booking_management/entity/Voucher.java"),

    @("repository/BookingRepository.java", "modules/booking_management/repository/BookingRepository.java"),
    @("repository/RoomBookingRepository.java", "modules/booking_management/repository/RoomBookingRepository.java"),
    @("repository/RoomRepository.java", "modules/booking_management/repository/RoomRepository.java"),
    @("repository/RoomTypeRepository.java", "modules/booking_management/repository/RoomTypeRepository.java"),
    @("repository/VoucherRepository.java", "modules/booking_management/repository/VoucherRepository.java"),

    @("service/BookingService.java", "modules/booking_management/service/BookingService.java"),

    @("dto/BookingSummary.java", "modules/booking_management/dto/BookingSummary.java"),
    @("dto/CreateBookingRequest.java", "modules/booking_management/dto/CreateBookingRequest.java"),
    @("dto/HomepageResponse.java", "modules/booking_management/dto/HomepageResponse.java"),
    @("dto/RoomSummary.java", "modules/booking_management/dto/RoomSummary.java"),
    @("dto/RoomTypeSummary.java", "modules/booking_management/dto/RoomTypeSummary.java"),

    @("controller/BookingController.java", "modules/booking_management/controller/BookingController.java")
)

# Package updates
$packageUpdates = @{
    "com.hotel.hms.entity" = "com.hotel.hms.modules.booking_management.entity"
    "com.hotel.hms.repository" = "com.hotel.hms.modules.booking_management.repository"
    "com.hotel.hms.service" = "com.hotel.hms.modules.booking_management.service"
    "com.hotel.hms.dto" = "com.hotel.hms.modules.booking_management.dto"
    "com.hotel.hms.controller" = "com.hotel.hms.modules.booking_management.controller"
}

# Move and update package declaration
foreach ($move in $moves) {
    $src = Join-Path $srcDir $move[0]
    $dest = Join-Path $srcDir $move[1]
    
    if (Test-Path $src) {
        $parent = Split-Path $dest -Parent
        if (!(Test-Path $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        
        $content = Get-Content -Raw -Path $src -Encoding UTF8
        
        # Calculate new package
        $destDir = (Split-Path $move[1] -Parent).Replace("\", ".").Replace("/", ".")
        $newPackage = "com.hotel.hms.$destDir"
        
        # Replace package header
        $content = $content -replace "(?m)^package\s+[\w\.]+;", "package $newPackage;"
        
        # Write to destination
        [System.IO.File]::WriteAllText($dest, $content, [System.Text.Encoding]::UTF8)
        Remove-Item $src
        Write-Host "Moved and updated: $($move[0]) -> $($move[1])"
    }
}

# Update all imports across Java files
$javaFiles = Get-ChildItem -Path $srcDir -Filter *.java -Recurse
foreach ($file in $javaFiles) {
    $content = Get-Content -Raw -Path $file.FullName -Encoding UTF8
    $modified = $false
    
    foreach ($oldPkg in $packageUpdates.Keys) {
        $newPkg = $packageUpdates[$oldPkg]
        $oldImport = "import $oldPkg."
        $newImport = "import $newPkg."
        
        if ($content.Contains($oldImport)) {
            $content = $content.Replace($oldImport, $newImport)
            $modified = $true
        }
    }
    
    if ($modified) {
        [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
        Write-Host "Updated imports in: $($file.FullName)"
    }
}

# Clean empty directories
$emptyCandidates = @("entity", "repository", "service", "dto", "controller")
foreach ($cand in $emptyCandidates) {
    $candPath = Join-Path $srcDir $cand
    if (Test-Path $candPath) {
        $items = Get-ChildItem -Path $candPath
        if ($items.Count -eq 0) {
            Remove-Item $candPath -Force
            Write-Host "Removed empty directory: $cand"
        }
    }
}
