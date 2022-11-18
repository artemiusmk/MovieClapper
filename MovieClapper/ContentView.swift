import SwiftUI
import AVKit
import Combine

struct ContentView: View {
    
    struct AnimationParams {
        let first: Double
        let last: Double
        let startTime: Double
        let endtime: Double
    }
    
    struct Constants {
        static let zDegreeAnimation = AnimationParams(
            first: -30, last: 0,
            startTime: 1, endtime: 1.7
        )
        static let xTransitionAnimation = AnimationParams(
            first: 0, last: -300,
            startTime: 2, endtime: 3
        )
        static let maxTime = 3.5
    }
    
    @State private var zDegree = Constants.zDegreeAnimation.first
    @State private var xTransition = Constants.xTransitionAnimation.first
    @ObservedObject private var animationManager = PauseModifierManager(maxTime: Constants.maxTime)
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                topPart
                bottomPart
            }
            .frame(width: 100)
            .offset(x: xTransition)
            .modifier(animationManager.modifier(
                propertyValue: $xTransition,
                propertyFinalValue: Constants.xTransitionAnimation.last,
                startTime: Constants.xTransitionAnimation.startTime,
                endTime: Constants.xTransitionAnimation.endtime
            ))
            playButton
            Spacer()
        }
        .onReceive(animationManager.$currentTime) {
            if $0 == 0 { reset() }
        }
    }
    
    var topPart: some View {
        Image("top-part")
            .resizable()
            .scaledToFit()
            .rotation3DEffect(
                .degrees(zDegree),
                axis: (x: 0, y: 0, z: 1),
                anchor: .bottomLeading
            )
            .modifier(animationManager.modifier(
                propertyValue: $zDegree,
                propertyFinalValue: Constants.zDegreeAnimation.last,
                startTime: Constants.zDegreeAnimation.startTime,
                endTime: Constants.zDegreeAnimation.endtime
            ))
    }
    
    var bottomPart: some View {
        Image("bottom-part")
            .resizable()
            .scaledToFit()
    }
    
    var playButton: some View {
        HStack {
            Button(animationManager.paused ? "▶️" : "⏸️") {
                animationManager.togglePaused()
            }
            .padding(24)
        }
    }
    
    private func reset() {
        zDegree = Constants.zDegreeAnimation.first
        xTransition = Constants.xTransitionAnimation.first
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

