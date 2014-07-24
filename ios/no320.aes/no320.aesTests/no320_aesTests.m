//
//  no320_aesTests.m
//  no320.aesTests
//
//  Created by alfred sang on 7/22/14.
//  Copyright (c) 2014 alfred sang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSData+AesEncryption.h"


NSString *NSDocumentsFolder()
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}

#define ORIGIN_STRING @"AES"
#define ENCRYPT_STRING @"1fb1e65c94fb8f0be382f47adbc88f"
#define BASE64_ENCRYPT_STRING @"H7HmXAlPuPC+OC9HCtvIjw"

#define key_file_path [NSString stringWithFormat:@"%@/%@",NSDocumentsFolder(),@"aes256.key"]
#define data_file_path [NSString stringWithFormat:@"%@/%@",NSDocumentsFolder(),@"aes256.data"]


@interface no320_aesTests : XCTestCase


@end

@implementation no320_aesTests


#pragma mark - Unit Test

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [self init_local_data];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
//    [super tearDown];
}

- (void)testEncryptWithKey
{
    NSString *plainText = @"AES";//明文
    NSData *plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    
    //为了测试，这里先把密钥写死
    Byte keyByte[] = {0x08,0x08,0x04,0x0b,0x02,0x0f,0x0b,0x0c,0x01,0x03,0x09,0x07,0x0c,0x03,
        0x07,0x0a,0x04,0x0f,0x06,0x0f,0x0e,0x09,0x05,0x01,0x0a,0x0a,0x01,0x09,
        0x06,0x07,0x09,0x0d};
    //byte转换为NSData类型，以便下边加密方法的调用
    NSData *keyData = [[NSData alloc] initWithBytes:keyByte length:32];
    //
    NSData *cipherTextData = [plainTextData AES256EncryptWithKey:keyData];
    Byte *plainTextByte = (Byte *)[cipherTextData bytes];
    for(int i=0;i<[cipherTextData length];i++){
        printf("%x",plainTextByte[i]);
    }
    
    // 'AES' encrypt to base64 := H7HmXAlPuPC+OC9HCtvIjw 1fb1e65c94fb8f0be382f47adbc88f
    NSString *base64_str = [cipherTextData newStringInBase64FromData];
    
    NSString *str = [cipherTextData hexadecimalString];
    
    XCTAssertEqualObjects(@"1fb1e65c94fb8f0be382f47adbc88f" ,str, @"解密成功");
}



- (void)testDecryptWithKey
{

    //byte转换为NSData类型，以便下边加密方法的调用
    NSData *keyData= [self get_key_data];
    NSData *encryptData= [self get_encryptdata_data];

    [self dump_data:encryptData desc:@"dsdsdsdsds"];
    
    

    NSString *base64_encrypt_str = [encryptData newStringInBase64FromData];
    
    XCTAssertEqualObjects(@"H7HmXAlPuPC+OC9HCtvIjw" ,base64_encrypt_str, @"解密成功");
    
    
    NSString *sss = [NSData base64encode:base64_encrypt_str];
    
    NSData *plainTextData = [sss dataUsingEncoding:NSUTF8StringEncoding];

    NSData *cipherTextData = [plainTextData AES256DecryptWithKey:keyData];

    [self dump_data:cipherTextData];

    NSString *str = [cipherTextData hexadecimalString];
//    XCTAssertEqualObjects(@"1fb1e65c94fb8f0be382f47adbc88f" ,str, @"解密成功");
}

#pragma mark - NSString
- (void)testGet_base64_encrypt_string{
    NSString *plain_text = ORIGIN_STRING;
    
    //为了测试，这里先把密钥写死
    Byte keyByte[] = {0x08,0x08,0x04,0x0b,0x02,0x0f,0x0b,0x0c,0x01,0x03,0x09,0x07,0x0c,0x03,
        0x07,0x0a,0x04,0x0f,0x06,0x0f,0x0e,0x09,0x05,0x01,0x0a,0x0a,0x01,0x09,
        0x06,0x07,0x09,0x0d};
    
    NSData *key_data = [[NSData alloc] initWithBytes:keyByte length:32];
    
    NSString *_base64_encrypt_string =  [NSString get_base64_encrypt_string: plain_text key_data: key_data];
    
    XCTAssertEqualObjects(@"H7HmXAlPuPC+OC9HCtvIjw" ,_base64_encrypt_string, @"解密成功");
}


- (void)testGet_base64_encrypt_string_with_key_bytes{
    // TODO:
}

#pragma mark - Private

- (void)init_local_data {
    Byte keyByte[] = {0x08,0x08,0x04,0x0b,0x02,0x0f,0x0b,0x0c,0x01,0x03,0x09,0x07,0x0c,0x03,
        0x07,0x0a,0x04,0x0f,0x06,0x0f,0x0e,0x09,0x05,0x01,0x0a,0x0a,0x01,0x09,
        0x06,0x07,0x09,0x0d};
    //byte转换为NSData类型，以便下边加密方法的调用
    NSData *keyData = [[NSData alloc] initWithBytes:keyByte length:32];
    [keyData writeToFile:key_file_path atomically:YES];
    
    NSData *plainTextData = [ORIGIN_STRING dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptTextData = [plainTextData AES256EncryptWithKey:keyData];
    
    [encryptTextData writeToFile:data_file_path atomically:YES];
}

- (NSData *)get_key_data{
    return [NSData dataWithContentsOfFile:key_file_path];
}

- (NSData *)get_encryptdata_data{
    return [NSData dataWithContentsOfFile:data_file_path];
}


/**
 * 打印日志，参数为NSData
 */
- (void)dump_data:(NSData *)encryptData {
    [self dump_data:encryptData desc: @"[DATA DUMP INFO]"];
}

/**
 * 打印日志，参数为NSData
 */
- (void)dump_data:(NSData *)encryptData desc:(NSString *)desc{
    NSLog(@"====================================================\n%@",desc);

    Byte *plainTextByte = (Byte *)[encryptData bytes];
    for(int i=0;i<[encryptData length];i++){
        printf("%x",plainTextByte[i]);
    }
    
    printf("\n====================================================\n");
}

@end
