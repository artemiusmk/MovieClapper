import SwiftUI

class PauseModifierManager: ObservableObject {
    
    @Published var paused = true
    @Published var currentTime = 0.0
    private var playStartedTime = 0.0
    private var playStartedDate: Date?
    private var animationsStartTime: Set<Double> = []
    private var maxTime: Double
    private var task: DispatchWorkItem?
    
    init(maxTime: Double, additionalTimeUpdates: [Double] = []) {
        self.maxTime = maxTime
        animationsStartTime.insert(maxTime)
        animationsStartTime.formUnion(additionalTimeUpdates)
    }
    
    func modifier(
        animatable: Binding<Double>,
        animatableToValue: Double,
        startTime: Double,
        endTime: Double
    ) -> PauseModifier {
        // at 0 time we usually reset animations,
        // so to avoid collisions of animatable values let's set min startTime to 0.1
        let startTime = max(0.1, startTime)
        
        // If a new animation starts earlier than the next one that was added earlier,
        // we must update the schedule
        if !paused, startTime > currentTime, (nextStartTime ?? 0) > startTime {
            animationsStartTime.insert(startTime)
            task?.cancel()
            scheduleCurrentTimeUpdate()
        } else {
            animationsStartTime.insert(startTime)
        }
        return PauseModifier(
            animatable: animatable,
            animatableToValue: animatableToValue,
            startTime: startTime,
            endTime: endTime,
            manager: self
        )
    }
    
    func togglePaused() {
        paused.toggle()
        if paused {
            task?.cancel()
            updateCurrentTime()
        } else {
            playStartedDate = Date()
            playStartedTime = currentTime
            scheduleCurrentTimeUpdate()
        }
    }
    
    private func scheduleCurrentTimeUpdate() {
        // kind of autoplay, we can disable (pause) it here
        if currentTime >= maxTime {
            seekToBegining()
        }
        
        guard !paused, let nextStartTime = nextStartTime else { return }
        
        task = DispatchWorkItem { [weak self] in
            self?.updateCurrentTime()
            self?.scheduleCurrentTimeUpdate()
        }
        if let task = task {
            DispatchQueue.main.asyncAfter(
                deadline: .now() + nextStartTime - currentTime,
                execute: task
            )
        }
    }
    
    private func updateCurrentTime() {
        currentTime = playStartedTime + abs(playStartedDate?.timeIntervalSinceNow ?? 0)
    }
    
    private func seekToBegining() {
        playStartedDate = Date()
        playStartedTime = 0
        currentTime = 0
    }
    
    private var nextStartTime: Double? {
        animationsStartTime.sorted().first { $0 > currentTime }
    }
}
