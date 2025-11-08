# PAWS App Security Implementation

## Overview
This document describes the implementation of app-specific authentication and access control for the PAWS Pet Management application. The system ensures that user accounts created through this app are restricted to only this application and cannot access other applications or dashboards within the same Firebase project.

## Key Features

### 1. App-Specific User Metadata
- Each user account is tagged with app-specific metadata:
  - `appId`: 'paws-app' (unique identifier for this app)
  - `appName`: 'PAWS Pet Management'
  - `userRole`: 'pet_owner'
  - `isActive`: boolean flag for account status
  - `appAccess`: object defining access permissions

### 2. Access Control Matrix
```json
{
  "appAccess": {
    "paws": true,           // Access to PAWS app
    "bathAndBark": false    // Explicitly denied access to other apps
  }
}
```

### 3. Authentication Flow
1. **User Signup**: Creates Firebase Auth account + app metadata
2. **User Login**: Verifies app membership before granting access
3. **Route Protection**: All protected routes check app access
4. **Data Access**: Firestore rules enforce app-specific permissions

## Implementation Details

### Authentication Service (`lib/auth/auth.dart`)
- `signUpWithEmail()`: Creates user account with app metadata
- `signInWithEmail()`: Verifies app access on login
- `signInWithGoogle()`: Handles Google OAuth with app restrictions
- `hasAppAccess()`: Checks if current user has app access
- `getAppAccessStatus()`: Returns detailed access information

### App Access Guard (`lib/widgets/app_access_guard.dart`)
- Middleware component that protects routes
- Checks user authentication and app membership
- Redirects unauthorized users to login
- Shows appropriate error messages for access denied

### Protected Routes
The following routes are protected by `AppAccessGuard`:
- `/home` - Main app dashboard
- `/profile` - User profile management
- `/pets` - Pet management interface

### Firestore Security Rules (`firestore.rules`)
- Enforces app-specific access at database level
- Users can only access their own data
- App membership verification on every request
- Denies access to unauthorized users/apps

## Security Benefits

### 1. App Isolation
- Users cannot access other applications in the same Firebase project
- Each app maintains its own user base
- Prevents cross-app data leakage

### 2. Role-Based Access
- Clear user role definitions
- Extensible permission system
- Easy to add new roles (admin, vet, etc.)

### 3. Data Protection
- Users can only access their own data
- Database-level security enforcement
- No unauthorized data access possible

### 4. Account Management
- Account status tracking (active/inactive)
- Login history monitoring
- Easy account deactivation

## Usage Examples

### Protecting a New Route
```dart
case '/new-feature':
  return MaterialPageRoute(
    builder: (_) => AppAccessGuard(
      child: NewFeaturePage(),
      loadingWidget: const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    ),
  );
```

### Checking App Access in Code
```dart
final authService = AuthService();
if (await authService.hasAppAccess()) {
  // User has access to this app
} else {
  // User does not have access
}
```

### Getting User Role
```dart
final userRole = await authService.getUserRole();
if (userRole == 'pet_owner') {
  // Handle pet owner specific logic
}
```

## Deployment Notes

### 1. Firebase Configuration
- Deploy the `firestore.rules` file to your Firebase project
- Ensure the rules are active in the Firebase Console

### 2. Testing
- Test with both new and existing user accounts
- Verify that unauthorized users cannot access protected routes
- Test Google OAuth flow with app restrictions

### 3. Monitoring
- Monitor Firestore security rule violations
- Track user access patterns
- Log authentication failures for debugging

## Troubleshooting

### Common Issues

1. **"App access denied" error**
   - User account was created outside of PAWS app
   - User document is missing app metadata
   - Solution: Recreate user account through PAWS signup

2. **Firestore permission errors**
   - Security rules not deployed
   - User document structure incorrect
   - Solution: Check Firestore rules and user data structure

3. **Google Sign-in issues**
   - OAuth configuration problems
   - App metadata not being set
   - Solution: Verify Google OAuth setup and error handling

### Debug Mode
Enable debug logging in the authentication service:
```dart
// Add to auth service methods
print('Debug: User access check for ${user.uid}');
print('Debug: Access status: $accessStatus');
```

## Future Enhancements

### 1. Multi-App Support
- Support for multiple related applications
- Shared user base with different permissions
- Cross-app data sharing (if needed)

### 2. Advanced Permissions
- Granular permission system
- Feature-based access control
- Time-based access restrictions

### 3. Audit Logging
- Track all access attempts
- Monitor user activity
- Compliance reporting

## Conclusion

This implementation provides a robust, secure foundation for app-specific user management. It ensures that PAWS app users cannot access other applications while maintaining a clean, maintainable codebase. The system is designed to be extensible for future security requirements and can easily accommodate additional authentication methods or permission levels.
