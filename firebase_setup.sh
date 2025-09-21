# Iniciar un nuevo proyecto de Firebase
firebase init

# Seleccionar las siguientes opciones:
# - Firestore
# - Authentication
# - Storage
# - Functions

# Configurar las reglas de seguridad para Firestore
cat > firestore.rules << EOL
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
      
      match /meditation_history/{sessionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    match /meditation_sessions/{sessionId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
    
    match /categories/{categoryId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
EOL

# Configurar las reglas de almacenamiento
cat > storage.rules << EOL
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /audio/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }
    
    match /images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
EOL

# Desplegar las reglas
firebase deploy --only firestore:rules,storage:rules 