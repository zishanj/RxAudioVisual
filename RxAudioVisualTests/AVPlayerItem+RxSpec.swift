import Quick
import Nimble
import RxSwift
import AVFoundation
@testable import RxAudioVisual

class AVPlayerItemSpec: QuickSpec {

  override func spec() {

    describe("KVO through rx") {

      var asset: AVAsset!
      var item: AVPlayerItem!
      var player: AVPlayer!
      var disposeBag: DisposeBag!

      beforeEach {
        asset = AVAsset(url: TestHelper.sampleURL)
        item = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: item)
        disposeBag = DisposeBag()
      }
      
      afterEach {
        player.pause()
      }

      it("should load asset") {
        var e: AVAsset?
        item.rx.asset.subscribe(onNext: { v in e = v }).disposed(by: disposeBag)
        expect(e).toEventuallyNot(beNil())
        expect(e).toEventually(equal(asset))
      }

      it("should load duration") {
        var e: CMTime?
        item.rx.duration.subscribe(onNext: { v in e = v }).disposed(by: disposeBag)
        expect(e).toEventuallyNot(beNil())
        expect(e).toEventuallyNot(equal(kCMTimeZero))
      }

      it("should load loadedTimeRanges") {
        var e: [NSValue]?
        item.rx.loadedTimeRanges.subscribe(onNext: { v in e = v }).disposed(by: disposeBag)
        expect(e).toEventuallyNot(beNil())
        expect(e).toEventuallyNot(beEmpty())
      }

      it("should load presentationSize") {
        var e: CMTime?
        item.rx.presentationSize.subscribe(onNext: { v in e = v }).disposed(by: disposeBag)
        expect(e).toEventuallyNot(beNil())
        expect(e).toEventually(equal(kCMTimeZero))
      }

      it("should load status") {
        var e: AVPlayerItemStatus?
        item.rx.status.subscribe(onNext: { v in e = v }).disposed(by: disposeBag)
        expect(e).toEventuallyNot(beNil())
        // FIXME: WHY???
        //expect(e).toEventually(equal(AVPlayerItemStatus.readyToPlay))
      }

      it("should load timebase") {
        var e: CMTimebase?
        item.rx.timebase.subscribe(onNext: { v in e = v }).disposed(by: disposeBag)
        expect(e).toEventuallyNot(beNil())
      }

      it("should load tracks") {
        var e: [AVPlayerItemTrack]?
        item.rx.tracks.subscribe(onNext: { v in e = v }).disposed(by: disposeBag)
        expect(e).toEventuallyNot(beNil())
        expect(e).toEventuallyNot(beEmpty())
      }

      it("should load seekableTimeRanges") {
        var e: [NSValue]?
        item.rx.seekableTimeRanges.subscribe(onNext: { v in e = v }).disposed(by: disposeBag)
        expect(e).toEventuallyNot(beNil())
        expect(e).toEventuallyNot(beEmpty())
      }

      it("should load isPlaybackLikelyToKeepUp") {
        var e: Bool?
        item.rx.isPlaybackLikelyToKeepUp.subscribe(onNext: { v in e = v }).disposed(by: disposeBag)
        expect(e).toEventuallyNot(beNil())
        player.play()
      }

      it("should load isPlaybackBufferEmpty") {
        var e: Bool?
        item.rx.isPlaybackBufferEmpty.subscribe(onNext: { v in e = v }).disposed(by: disposeBag)
        expect(e).toEventuallyNot(beNil())
      }

      it("should load isPlaybackBufferFull") {
        player.play()
        var e: Bool?
        item.rx.isPlaybackBufferFull.subscribe(onNext: { v in e = v }).disposed(by: disposeBag)
        expect(e).toEventuallyNot(beNil())
      }

    }

    describe("Notification through rx") {

      var asset: AVAsset!
      var item: AVPlayerItem!
      var disposeBag: DisposeBag!

      beforeEach {
        let path = Bundle(for: AVPlayerItemSpec.self).path(forResource: "sample", ofType: "mov")
        let url = URL(string: path!)
        asset = AVAsset(url: url!)
        item = AVPlayerItem(asset: asset)
        disposeBag = DisposeBag()
      }

      it("should not receive didPlayToEnd of another item") {
        var e: Notification? = nil
        item.rx.didPlayToEnd.subscribe(onNext: { v in
          e = v
        }).disposed(by: disposeBag)
        let anotherItem = AVPlayerItem(asset: asset)
        NotificationCenter.default.post(name: .AVPlayerItemDidPlayToEndTime, object: anotherItem)
        expect(e).toEventually(beNil())
      }

      it("should receive didPlayToEnd") {
        var e: Notification? = nil
        item.rx.didPlayToEnd.subscribe(onNext: { v in
          e = v
        }).disposed(by: disposeBag)
        NotificationCenter.default.post(name: .AVPlayerItemDidPlayToEndTime, object: item)
        expect(e).toEventuallyNot(beNil())
        expect(e!.name).to(equal(Notification.Name.AVPlayerItemDidPlayToEndTime))
      }

      it("should receive timeJumped") {
        var e: Notification? = nil
        item.rx.timeJumped.subscribe(onNext: { v in
          e = v
        }).disposed(by: disposeBag)
        NotificationCenter.default.post(name: .AVPlayerItemTimeJumped, object: item)
        expect(e).toEventuallyNot(beNil())
        expect(e!.name).to(equal(Notification.Name.AVPlayerItemTimeJumped))
      }

      it("should receive failedToPlayToEndTime") {
        var e: Notification? = nil
        item.rx.failedToPlayToEndTime.subscribe(onNext: { v in
          e = v
        }).disposed(by: disposeBag)
        NotificationCenter.default.post(name: .AVPlayerItemFailedToPlayToEndTime, object: item)
        expect(e).toEventuallyNot(beNil())
        expect(e!.name).to(equal(Notification.Name.AVPlayerItemFailedToPlayToEndTime))
      }

      it("should receive playbackStalled") {
        var e: Notification? = nil
        item.rx.playbackStalled.subscribe(onNext: { v in
          e = v
        }).disposed(by: disposeBag)
        NotificationCenter.default.post(name: .AVPlayerItemPlaybackStalled, object: item)
        expect(e).toEventuallyNot(beNil())
        expect(e!.name).to(equal(Notification.Name.AVPlayerItemPlaybackStalled))
      }

      it("should receive newAccessLogEntry") {
        var e: Notification? = nil
        item.rx.newAccessLogEntry.subscribe(onNext: { v in
          e = v
        }).disposed(by: disposeBag)
        NotificationCenter.default.post(name: .AVPlayerItemNewAccessLogEntry, object: item)
        expect(e).toEventuallyNot(beNil())
        expect(e!.name).to(equal(Notification.Name.AVPlayerItemNewAccessLogEntry))
      }

      it("should receive newErrorLogEntry") {
        var e: Notification? = nil
        item.rx.newErrorLogEntry.subscribe(onNext: { v in
          e = v
        }).disposed(by: disposeBag)
        NotificationCenter.default.post(name: .AVPlayerItemNewErrorLogEntry, object: item)
        expect(e).toEventuallyNot(beNil())
        expect(e!.name).to(equal(Notification.Name.AVPlayerItemNewErrorLogEntry))
      }

    }

  }
}
