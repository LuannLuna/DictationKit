import SwiftUI

struct TranscriptView: View {
    let currentTranscript: String
    let lastTranscript: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !currentTranscript.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Transcript")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(currentTranscript)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
            }

            if !lastTranscript.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Last Transcript")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(lastTranscript)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentTranscript)
        .animation(.easeInOut(duration: 0.3), value: lastTranscript)
    }
}

#if DEBUG
#Preview {
    TranscriptView(
        currentTranscript: "Hello World",
        lastTranscript: "My last transcript"
    )
}
#endif
