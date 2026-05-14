import SwiftUI

struct RecordingButton: View {
    let isRecording: Bool
    let onStart: () -> Void
    let onStop: () -> Void

    var body: some View {
        Button(action: {
            isRecording ? onStop() : onStart()
        }) {
            ZStack {
                Circle()
                    .fill(isRecording ? Color.red : Color.blue)
                    .frame(width: 120, height: 120)
                    .shadow(radius: 10)

                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .scaleEffect(isRecording ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isRecording)
    }
}

#Preview {
    RecordingButton(isRecording: false, onStart: {}, onStop: {})
}
