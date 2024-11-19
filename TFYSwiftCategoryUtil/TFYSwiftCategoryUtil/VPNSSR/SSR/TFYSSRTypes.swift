//
//  TFYSSRTypes.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/11/19.
//

import Foundation

/// SSR加密方法
public enum SSREncryptMethod: String, Codable {
    case none = "none"
    case table = "table"
    case rc4 = "rc4"
    case rc4_md5 = "rc4-md5"
    case aes_128_cfb = "aes-128-cfb"
    case aes_192_cfb = "aes-192-cfb"
    case aes_256_cfb = "aes-256-cfb"
    case bf_cfb = "bf-cfb"
    case camellia_128_cfb = "camellia-128-cfb"
    case camellia_192_cfb = "camellia-192-cfb"
    case camellia_256_cfb = "camellia-256-cfb"
    case cast5_cfb = "cast5-cfb"
    case des_cfb = "des-cfb"
    case idea_cfb = "idea-cfb"
    case rc2_cfb = "rc2-cfb"
    case seed_cfb = "seed-cfb"
    case salsa20 = "salsa20"
    case chacha20 = "chacha20"
    case chacha20_ietf = "chacha20-ietf"
}

/// SSR协议类型
public enum SSRProtocol: String, Codable {
    case origin = "origin"
    case verify_simple = "verify_simple"
    case verify_sha1 = "verify_sha1"
    case auth_sha1 = "auth_sha1"
    case auth_sha1_v2 = "auth_sha1_v2"
    case auth_sha1_v4 = "auth_sha1_v4"
    case auth_aes128_md5 = "auth_aes128_md5"
    case auth_aes128_sha1 = "auth_aes128_sha1"
    case auth_chain_a = "auth_chain_a"
    case auth_chain_b = "auth_chain_b"
}

/// SSR混淆类型
public enum SSRObfs: String, Codable {
    case plain = "plain"
    case http_simple = "http_simple"
    case http_post = "http_post"
    case tls1_2_ticket_auth = "tls1.2_ticket_auth"
}

/// 代理类型
public enum ProxyType: String, Codable {
    case http = "HTTP"
    case socks5 = "SOCKS5"
    case none = "NONE"
}

