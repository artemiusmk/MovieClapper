import SwiftUI

struct PauseModifier: AnimatableModifier {
    
    @ObservedObject private var manager: PauseModifierManager
    @Binding private var propertyValue: Double
    private var propertyFinalValue: Double
    private var startTime: Double
    private var endTime: Double
    @State private var currentTime: Double = 0
    @State private var paused: Bool = true
    @State private var animationPaused = true
    private var propertyCurrentValue: Double
    
    init(propertyValue: Binding<Double>,
         propertyFinalValue: Double,
         startTime: Double,
         endTime: Double,
         manager: PauseModifierManager
    ) {
        self._propertyValue = propertyValue
        self.propertyFinalValue = propertyFinalValue
        self.startTime = startTime
        self.endTime = endTime
        self.propertyCurrentValue = propertyValue.wrappedValue
        self.manager = manager
    }

    var animatableData: Double {
        get { propertyCurrentValue }
        set { propertyCurrentValue = newValue }
    }

    func body(content: Content) -> some View {
        content
            .onReceive(manager.$paused) {
                paused = $0
                updateAnimation()
            }
            .onReceive(manager.$currentTime) {
                currentTime = $0
                resetIfNeeded()
                updateAnimation()
            }
    }
    
    private func updateAnimation() {
        // animationPaused is internal flag of this modifier
        // needed to avoid running the same animation multiple times in a row
        guard currentAnimationTimeFrame, animationPaused != paused else { return }
        animationPaused.toggle()
        if paused {
            // Stop animation
            withAnimation(.easeInOut(duration: 0)) {
                propertyValue = propertyCurrentValue
            }
        } else {
            // Continue animation
            // .easeInOut animation can be replaced by another animation
            withAnimation(.easeInOut(duration: remainingTime)) {
                propertyValue = propertyFinalValue
            }
        }
    }
    
    private var remainingTime: Double {
        endTime - currentTime
    }
    
    private var currentAnimationTimeFrame: Bool {
        startTime <= currentTime && currentTime < endTime
    }
    
    private func resetIfNeeded() {
        if !currentAnimationTimeFrame {
            animationPaused = true
        }
    }
}
