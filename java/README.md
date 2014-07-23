# no320.aes256 java version

之前在项目上用到AES256加密解密算法，刚开始在java端加密解密都没有问题，在iOS端加密解密也没有问题。但是奇怪的是在java端加密后的文件在iOS端无法正确解密打开，然后简单测试了一下，发现在java端和iOS端采用相同明文，相同密钥加密后的密文不一样！上网查了资料后发现iOS中AES加密算法采用的填充是PKCS7Padding，而java不支持PKCS7Padding，只支持PKCS5Padding。我们知道加密算法由算法+模式+填充组成，所以这两者不同的填充算法导致相同明文相同密钥加密后出现密文不一致的情况。那么我们需要在java中用PKCS7Padding来填充，这样就可以和iOS端填充算法一致了。

## run demo 

```
./build.sh
```

##  依赖说明

此项目共依赖3个jar文件，说明如下

### jce_policy-6.zip 

（在jdk7下面要用UnlimitedJCEPolicyJDK7.zip）

- 下载链接：http://www.oracle.com/technetwork/java/javase/downloads/jce-6-download-429243.html

下载解压后将里边的两个jar包(local_policy.jar,US_export_policy.jar)替换掉jdk安装路径下security文件夹中的两个包。

### bcprov-jdk16-139.jar 

要实现在java端用PKCS7Padding填充，需要用到bouncycastle组件来实现

下载链接：http://www.bouncycastle.org

### commons-codec-1.9

commons-codec-1.9.jar主要是进行base64编解码


