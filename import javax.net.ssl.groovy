import javax.net.ssl.HostnameVerifier
import javax.net.ssl.HttpsURLConnection
import javax.net.ssl.SSLContext
import javax.net.ssl.TrustManager
import javax.net.ssl.X509TrustManager

// 创建信任管理器，信任所有证书
def nullTrustManager = [
    checkClientTrusted: { chain, authType -> },
    checkServerTrusted: { chain, authType -> },
    getAcceptedIssuers: { null }
] as X509TrustManager

// 创建主机名验证器，接受所有主机名
def nullHostnameVerifier = [
    verify: { hostname, session -> true }
] as HostnameVerifier

// 初始化SSL上下文
SSLContext sc = SSLContext.getInstance("SSL")
sc.init(null, [nullTrustManager] as TrustManager[], null)

// 设置默认的SSLSocketFactory和HostnameVerifier
HttpsURLConnection.setDefaultSSLSocketFactory(sc.socketFactory)
HttpsURLConnection.setDefaultHostnameVerifier(nullHostnameVerifier)

// 示例：发送HTTPS请求
def url = new URL("https://example.com")
HttpsURLConnection connection = url.openConnection() as HttpsURLConnection
connection.requestMethod = "GET"

// 处理响应
def response = connection.inputStream.text
println(response)