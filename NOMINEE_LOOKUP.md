# Nominee Lookup Tool

This project includes two ways to lookup nominees by their ID and see all their nominated films:

## 1. GUI Screen (Flutter App)

Navigate to "Nominee ID Lookup" in the app drawer. This provides a user-friendly interface to:
- Enter a nominee ID (e.g., `nm0001932`)
- View all their nominated films in a list
- Print detailed information to the console

## 2. Command Line Tool

Run from the project root:
```bash
dart bin/nominee_lookup.dart <nominee_id>
```

### Examples:

```bash
# Look up Richard Barthelmess
dart bin/nominee_lookup.dart nm0001932

# Look up Emil Jannings
dart bin/nominee_lookup.dart nm0417837

# Look up Janet Gaynor
dart bin/nominee_lookup.dart nm0310980
```

## Sample Output:

```
=== NOMINATIONS FOR Richard Barthelmess (ID: nm0001932) ===
Total nominations found: 2
Films in nominee record: [tt0019217, tt0018253]

1. The Noose (1927)
   Category: ACTOR
   Winner: NO
   Film ID: tt0019217
   Nominees: Richard Barthelmess
   Nominee IDs: nm0001932

2. The Patent Leather Kid (1927)
   Category: ACTOR
   Winner: NO
   Film ID: tt0018253
   Nominees: Richard Barthelmess
   Nominee IDs: nm0001932

STATISTICS:
Regular nominations: 2
Wins: 0
Special awards: 0
========================================
```

## How It Works:

1. **Database Lookup**: The tool uses ObjectBox to look up the nominee by their ID
2. **Film Matching**: Searches through all Oscar winners for entries that contain the nominee ID (handles multiple nominees separated by "|")
3. **Statistics**: Calculates nominations, wins, and special awards using the NomineeNominationsService
4. **Display**: Shows all relevant information including film details, category, and winner status

## Integration:

- Uses the `DatabaseService` for ObjectBox queries
- Uses the `NomineeNominationsService` for statistics calculation  
- Handles multiple nominees in a single nomination (separated by "|")
- Provides detailed output for debugging and analysis
