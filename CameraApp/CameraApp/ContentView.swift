//
//  ContentView.swift
//  CameraApp
//
//  Created by kore omodara on 3/25/24.
//

import SwiftUI
import Vision

struct ContentView: View {
    @State private var capture = CaptureHandler()
    @State private var isPinched = false
    @State private var isNotPinched = false

    
    var body: some View {
        NavigationStack {
            ZStack{
                Color.black
                capture.preview?
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(alignment: .topLeading, content: {
                        Canvas { ctx, size in
                            for face in capture.faces {
                                //drawFaceBoundingBox(box: face.boundingBox, ctx: ctx, size: size)
                                drawFaceRegion(box: face.boundingBox, region: face.landmarks?.faceContour, ctx: ctx, size: size, closed: false)
                                drawFaceRegion(box: face.boundingBox, region: face.landmarks?.leftEye, ctx: ctx, size: size)
                                drawFaceRegion(box: face.boundingBox, region: face.landmarks?.rightEye, ctx: ctx, size: size)
                                drawFaceRegion(box: face.boundingBox, region: face.landmarks?.nose, ctx: ctx, size: size)
                                //add eyebrows, pupils, outer and inner lips ? 
                            }
                            for hand in capture.hands {
                                drawFingerPoints(hand: hand, ctx: ctx, size: size)
                            }
                        }
                    })
                //make conditional for the isPinched to display emoji
                //FIX
                if isPinched == true {
                    Text("🤏🏾")
                        .font(.system(size: 60))
                        //.foregroundColor(.white) ?not needed
                    
                } else if isNotPinched == true {
                    Text("✋🏾")
                        .font(.system(size: 60))
                        //.foregroundColor(.white) ?
                }
                VStack {
                    HStack {
                        Circle()
                            .stroke(.white, lineWidth: 3)
                            .fill(isPinched == true ? .pink : .clear)
                            .frame(width: 50, height: 50)
                        Spacer()

                    }
                    Spacer()
                }
            }
            .ignoresSafeArea()
            .statusBarHidden(true)
            .toolbarColorScheme(.dark, for: .bottomBar, .tabBar, .automatic, .navigationBar)
            .toolbar(.hidden, for: .tabBar, .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    //button to trigger capture & menu to select the camera we want
                    Spacer()
                    Button(action: {
                        //capture code
                        capture.capturePhoto()
                    }, label: {
                        Image(systemName: "camera.circle")
                            .font(.largeTitle)
                    })
                    
                    Spacer()
                    
                    Menu {
                        ForEach(capture.discoverySession?.devices ?? [], id: \.uniqueID) { device in
                            Button(action: {
                                //change the input
                                capture.changeCameraInput(device: device)
                            }, label: {
                                if capture.isCurrentInput(device: device) {
                                    Label(device.localizedName, systemImage: "camera.fill")
                                }
                                else {
                                    Label(device.localizedName, systemImage: "camera")
                                }
                            })
                        }
                    } label: {
                        Label("Camera Menu ", systemImage: "arrow.triangle.2.circlepath.camera")
                    }
                }
            }
        }
        .onAppear {
            capture.gestureProcessor.didChangeStateClosure = { state in
                self.handleGestureStateChange(state: state)
            }
        }
    }
    
    func drawFingerPoints(hand: VNHumanHandPoseObservation, ctx: GraphicsContext, size: CGSize) {
        guard let fingers = try? hand.recognizedPoints(.all) else { return }
        let fingerPoints = fingers.values.filter {
            $0.confidence > 0.3
        }.map {
            canvasPointsForNormalizedRect(norm: $0.location, box: capture.canvasFrame, orientation: capture.currentOrientation)
        }
        let circleSize = 8.0
        let circleRadius = circleSize / 2.0
        for point in fingerPoints {
            let cornerPoint = CGPoint(x: point.x - circleRadius, y: point.y - circleRadius)
            ctx.stroke(Circle().path(in: CGRect(origin: cornerPoint, size: CGSize(width: circleSize, height: circleSize))), with: .color(.white), lineWidth: 1)
        }
    }
    
    func handleGestureStateChange(state: HandGestureProcessor.State) {
        switch state {
        case .pinched:
            print("pinched")
            isPinched = true
            isNotPinched = false
        case .possiblePinch:
            print("possible pinch")
            isPinched = false
            isNotPinched = true
        case .apart:
            print("apart")
            isPinched = false
            isNotPinched = true
        case .possibleApart:
            print("possible apart")
            isPinched = false
            isNotPinched = true
        case .unknown:
            print("unknownT")
            isPinched = false
            isNotPinched = false
        }
    }
    
    func drawFaceBoundingBox(box: CGRect, ctx: GraphicsContext, size: CGSize) {
        let canvasBox = canvasRectForNormalizedRect(norm: box, frame: capture.canvasFrame, orientation: capture.currentOrientation)
        ctx.stroke(RoundedRectangle(cornerRadius: 6).path(in: canvasBox), with: .color(.white), lineWidth: 3.0)
    }
    //Fixed
    func drawFaceRegion(box: CGRect, region: VNFaceLandmarkRegion2D?, ctx: GraphicsContext, size: CGSize, closed: Bool = true) {
        guard let region = region else { return }
        let canvasBox = canvasRectForNormalizedRect(norm: box, frame: capture.canvasFrame, orientation: capture.currentOrientation)
        let canvasPoints = region.normalizedPoints.compactMap({ canvasPointsForNormalizedRect(norm: $0, box: canvasBox, orientation: capture.currentOrientation)})
        let path = Path { path in
            path.addLines(canvasPoints)
            if closed {
                path.closeSubpath()
            }
        }
        ctx.stroke(path, with: .color(.pink), lineWidth: 1.0)
    }
}

#Preview {
    ContentView()
}


func canvasRectForNormalizedRect(norm: CGRect, frame: CGRect, orientation: InterfaceOrientation) -> CGRect {
    //portrait version
    let maxY = 1.0 - norm.minY
    let minY = 1.0 - norm.maxY
    let newH = maxY - minY
    let rect = CGRect (
        x: frame.minX + minY * frame.width,
        y: frame.minY + norm.minX * frame.height,
        width: newH * frame.width,
        height: norm.width * frame.height)
        
    return rect
    
}
//Fixed
func canvasPointsForNormalizedRect(norm: CGPoint, box: CGRect, orientation: InterfaceOrientation) -> CGPoint {
    if orientation == .landscapeLeft {
        let point = CGPoint (
            x: box.minX + (1.0 - norm.x) * box.width,
            y: box.minY + (1.0 - norm.y) * box.height)
        return point
    }
    else if orientation == .landscapeRight {
        let point = CGPoint (
            x: box.minX + norm.x * box.width,
            y: box.minY + norm.y * box.height)
        return point
    }
    else {
        let point = CGPoint (
            x: box.minX + (1.0 - norm.y) * box.width,
            y: box.minY + norm.x * box.height)
        return point
    }
}
