# MACH-SPS (Beta)

Bu paket şu an sadece SPM ile yüklenebilmektedir.

<b>Kurulum:</b>
```Swift
import MACH_SPS

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Strimus.shared.configure(key: "test_key")
        return true
    }
```



<b>Yayın Listesini Çekme:</b>

```Swift
import MACH_SPS

private func getStreams(type: StreamListType) { // StreamListType: .live, .past
    Strimus.shared.getStreams(type: type) { [weak self] streams, error in
        if let streams {
            self?.streams = streams
        } else {
            print("failed to get streams \(error?.localizedDescription ?? "-")")
        }
    }
}
```


<b>Yayın Oynatma:</b>

```Swift
import MACH_SPS

class PlayerViewController: UIViewController {
    private var player = SPSPlayer()
    private var playerView: SPSPlayerView?
  
    private func getPlayerView(url: URL) { //url: Stream datasında gelen yayın veya video url'i
        let playerView = player.getPlayerView(url: url)
        self.playerView = playerView
        view.addSubview(playerView)
        playerView.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
        playerView.delegate = self
    }
 }
  
 extension PlayerViewController: SPSPlayerDelegate {
    
    func stateUpdated(state: SPSPlayerState) {
        if playerView?.state == .ready {
            playerView?.play()
        }
    }
    
    func playerError(error: Error) {
        print("player error \(error)") 
    }
    
}
 ```
 
 <b>Yayın Başlatma:</b>
 
 <i>Authentication:</i> 
 Yayın başlatabilmek için kendi server'ınız ile strimus rest-api'den [token](http://164.92.178.132:5555/api-docs/) almalısınız, güvenlik sebebiyle strimus sdk'da token oluşturulamaz. uniqueId strimus'tan bağımsız olarak yayıncının kendi tarafınızdaki user id'sidir.
 
 ```Swift
 Strimus.shared.setStreamerData(uniqueId: {your-user-id}, streamerToken: {token-from-strimus-rest-api})
 ```
 
 
 <i>Yayın oluşturma:</i>
  ```Swift
 class BroadcasterViewController: UIViewController {

    private let spsBroadcaster = SPSBroadcaster()
    private var broadcasterView: SPSBroadcasterView?
    
     private func getBroadcaster(source: BroadcastSource) { //source: .aws, .mux
        broadcasterView = spsBroadcaster.getBroadcasterView(source: source)
        broadcasterView?.createStream(source: source)
        broadcasterView?.delegate = self
    }
 }
 
 extension BroadcasterViewController: SPSBroadcasterDelegate {
    
    func stateUpdated(state: SPSBroadcasterState) { //Yayın durumunu geri döner
        
    }
    
    func streamIsReady(preview: UIView?) { // Yayın ön izlemesi hazır olduğunda Ön İzleme View'ini döner. 
        guard let preview else { return }
        DispatchQueue.main.async { [weak self] in
            self?.videoView.subviews.forEach({ $0.removeFromSuperview() })
            self?.videoView.addSubview(preview)
            preview.snp.makeConstraints({ make in
                make.edges.equalToSuperview()
            })
        }
    }
   
}
  ```
 
 <i>Yayın Başlatma/Durdurma:</i>
  ```Swift
  if broadcasterView?.state == .connected {
       broadcasterView?.stopStream()
  } else {
      broadcasterView?.startStream()
  }
   ```
 
 
 
