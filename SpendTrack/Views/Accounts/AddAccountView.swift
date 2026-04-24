import SwiftUI
import LinkKit

struct AddAccountView: View {
    @EnvironmentObject var vm: AccountsViewModel
    @SwiftUI.Environment(\.modelContext) private var modelContext
    @SwiftUI.Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "link.badge.plus")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)

                VStack(spacing: 8) {
                    Text("Connect a Bank Account")
                        .font(.title2.bold())
                    Text("SpendTrack uses Plaid to securely connect to thousands of US banks. Your credentials are never stored.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                VStack(spacing: 12) {
                    featureRow(icon: "lock.shield.fill", text: "256-bit encryption — bank-grade security")
                    featureRow(icon: "eye.slash.fill", text: "Read-only access — we can't move money")
                    featureRow(icon: "flag.fill", text: "US accounts only")
                }
                .padding(.horizontal, 32)

                Spacer()

                if let error = vm.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button {
                    Task { await vm.fetchLinkToken() }
                } label: {
                    Group {
                        if vm.isLoading {
                            HStack {
                                ProgressView().tint(.white)
                                Text("Loading…")
                            }
                        } else {
                            Text("Connect Account")
                        }
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(vm.isLoading)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationTitle("Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .fullScreenCover(isPresented: $vm.showPlaidLink) {
                if let token = vm.linkToken {
                    PlaidLinkController(
                        linkToken: token,
                        onSuccess: { publicToken in
                            vm.showPlaidLink = false
                            Task {
                                await vm.handlePlaidSuccess(
                                    publicToken: publicToken,
                                    modelContext: modelContext
                                )
                                dismiss()
                            }
                        },
                        onExit: { _ in
                            vm.showPlaidLink = false
                        }
                    )
                }
            }
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
}

// MARK: - Plaid Link UIKit Wrapper

struct PlaidLinkController: UIViewControllerRepresentable {
    let linkToken: String
    let onSuccess: (String) -> Void
    let onExit: (Error?) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        var linkConfig = LinkTokenConfiguration(token: linkToken) { success in
            onSuccess(success.publicToken)
        }
        linkConfig.onExit = { exit in
            onExit(exit.error)
        }

        switch Plaid.create(linkConfig) {
        case .success(let handler):
            context.coordinator.handler = handler
            let vc = UIViewController()
            vc.view.backgroundColor = .systemBackground
            // Delay to let the view hierarchy settle
            DispatchQueue.main.async {
                handler.open(presentUsing: .viewController(vc))
            }
            return vc
        case .failure(let error):
            onExit(error)
            return UIViewController()
        }
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator {
        var handler: Handler?
    }
}
