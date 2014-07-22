//
//  no320_aesTests.m
//  no320.aesTests
//
//  Created by alfred sang on 7/22/14.
//  Copyright (c) 2014 alfred sang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSData+AesEncryption.h"


@interface no320_aesTests : XCTestCase


@end

@implementation no320_aesTests


- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
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
    
    
    NSString *str = [cipherTextData hexadecimalString];
    
    XCTAssertEqualObjects(@"1fb1e65c94fb8f0be382f47adbc88f" ,str, @"解密成功");
}

- (void)testDecryptWithKey
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
    
    NSString *str = @"1fb1e65c94fb8f0be382f47adbc88f";
    
    NSData *cipherTextData1 = [plainTextData AES256DecryptWithKey:cipherTextData];
    
    str = [cipherTextData1 hexadecimalString];

    
//    XCTAssertEqualObjects(@"1fb1e65c94fb8f0be382f47adbc88f" ,str, @"解密成功");
}






@end
