import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Login")) {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                }
                
                Button("Sign In") {
                    authViewModel.signIn(email: email, password: password) { result in
                        switch result {
                        case .success:
                            // Handle successful login
                            break
                        case .failure(let error):
                            alertMessage = error.localizedDescription
                            showAlert = true
                        }
                    }
                }
                
                NavigationLink("Create Account", destination: SignUpView())
            }
            .navigationTitle("Postcard Collector")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Form {
            Section(header: Text("Create Account")) {
                TextField("Username", text: $username)
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                SecureField("Password", text: $password)
                SecureField("Confirm Password", text: $confirmPassword)
            }
            
            Button("Sign Up") {
                if password == confirmPassword {
                    authViewModel.signUp(email: email, password: password, username: username) { result in
                        switch result {
                        case .success:
                            // Handle successful signup
                            break
                        case .failure(let error):
                            alertMessage = error.localizedDescription
                            showAlert = true
                        }
                    }
                } else {
                    alertMessage = "Passwords do not match"
                    showAlert = true
                }
            }
        }
        .navigationTitle("Sign Up")
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    LoginView()
}
