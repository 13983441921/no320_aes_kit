//
//  Encryption.m
//  ssss
//
//  Created by alfred sang on 7/20/14.
//  Copyright (c) 2014 alfred sang. All rights reserved.
//
// 此段代码多不是本人所写，日后重构

#import "NSData+AesEncryption.h"
#import <CommonCrypto/CommonCrypto.h>

static char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";




@implementation NSData (AesEncryption)

- (NSData *)AES256EncryptWithKey:(NSData *)key   //加密
{
    
    //AES256加密，密钥应该是32位的
    //const void * keyPtr2 = [key bytes];
    //char (*keyPtr)[32] = keyPtr2;
    
    //对于块加密算法，输出大小总是等于或小于输入大小加上一个块的大小
    //所以在下边需要再加上一个块的大小
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding/*这里就是刚才说到的PKCS7Padding填充了*/ | kCCOptionECBMode,
                                          [key bytes], kCCKeySizeAES256,
                                          NULL,/* 初始化向量(可选) */
                                          [self bytes], dataLength,/*输入*/
                                          buffer, bufferSize,/* 输出 */
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);//释放buffer
    
    return nil;
}


- (NSData *)AES256DecryptWithKey:(NSData *)key   //解密
{
    
    //同理，解密中，密钥也是32位的
    const void * keyPtr2 = [key bytes];
    char (*keyPtr)[32] = keyPtr2;
    
    //对于块加密算法，输出大小总是等于或小于输入大小加上一个块的大小
    //所以在下边需要再加上一个块的大小
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding/*这里就是刚才说到的PKCS7Padding填充了*/ | kCCOptionECBMode,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL,/* 初始化向量(可选) */
                                          [self bytes], dataLength,/* 输入 */
                                          buffer, bufferSize,/* 输出 */
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    
    return nil;
}
 
 
- (NSString *)newStringInBase64FromData            //追加64编码
{
    NSMutableString *dest = [[NSMutableString alloc] initWithString:@""];
    unsigned char * working = (unsigned char *)[self bytes];
    int srcLen = [self length];
    
    for (int i=0; i<srcLen; i += 3) {
        for (int nib=0; nib<4; nib++) {
            int byt = (nib == 0)?0:nib-1;
            int ix = (nib+1)*2;
            if (i+byt >= srcLen) break;
            unsigned char curr = ((working[i+byt] << (8-ix)) & 0x3F);
            if (i+nib < srcLen) curr |= ((working[i+nib] >> ix) & 0x3F);
            [dest appendFormat:@"%c", base64[curr]];
        }
    }
    return dest;
}

+ (NSString*)base64encode:(NSString*)str
{
    if ([str length] == 0)
        return @"";
    
    const char *source = [str UTF8String];
    int strlength  = strlen(source);
    char *characters = malloc(((strlength + 2) / 3) * 4);
    
    if (characters == NULL)
        return nil;
    
    NSUInteger length = 0;
    NSUInteger i = 0;
    
    while (i < strlength) {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        
        while (bufferLength < 3 && i < strlength)
            buffer[bufferLength++] = source[i++];
        
        characters[length++] = base64[(buffer[0] & 0xFC) >> 2];
        characters[length++] = base64[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        
        if (bufferLength > 1)
            characters[length++] = base64[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        
        if (bufferLength > 2)
            characters[length++] = base64[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    
    NSString *g = [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
    
    return g;
}

- (NSString *)stringFromHexString:(NSString *)hexString {
    
    // The hex codes should all be two characters.
    if (([hexString length] % 2) != 0)
        return nil;
    
    NSMutableString *string = [NSMutableString string];
    
    for (NSInteger i = 0; i < [hexString length]; i += 2) {
        
        NSString *hex = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSInteger decimalValue = 0;
        sscanf([hex UTF8String], "%x", &decimalValue);
        [string appendFormat:@"%c", decimalValue];
    }
    
    return string;
}

#pragma mark - String Conversion
- (NSString *)hexadecimalString
{
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */
    
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
    
    if (!dataBuffer)
    {
        return [NSString string];
    }
    
    NSUInteger          dataLength  = [self length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
    {
        [hexString appendFormat:@"%x", (unsigned int)dataBuffer[i]];
    }
    
    return [NSString stringWithString:hexString];
}

#pragma mark - Utils Method by alfred.sang



@end




@implementation NSString (AesEncryption)

/**
 * 返回加密后的base46字符串
 *
 * @param plain_text（NSString）
 * @param key_data  （NSData）
 */
+ (NSString *)get_base64_encrypt_string:(NSString *)plain_text key_data:(NSData *)key_data{
    NSData *plainTextData = [plain_text dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipherTextData = [plainTextData AES256EncryptWithKey:key_data];
    
    return [cipherTextData newStringInBase64FromData];
}


/**
 * 返回加密后的base46字符串 todo
 *
 * @param plain_text（NSString）
 * @param key_data  （NSData）
 */
+ (NSString *)get_base64_encrypt_string:(NSString *)plain_text key_byte_arr:(id)key_byte_arr{
    NSData *key_data = [[NSData alloc] initWithBytes:(Byte)key_byte_arr length:32];
    
    return [NSString get_base64_encrypt_string:plain_text key_data:key_data];
}


@end