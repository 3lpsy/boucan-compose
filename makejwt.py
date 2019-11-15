#!/usr/bin/env python3

from datetime import timedelta, datetime
import argparse
import uuid
import sys
from os import environ
import jwt

if not getattr(jwt, "encode", None):
    print(
        "JWT Module does not have the 'encode' method. This is probably the wrong jwt module. You need pyjwt: pip install pyjwt"
    )
    sys.exit(1)

NODE_SCOPES = "profile dns-request:create dns-request:list http-request:create http-request:list zone:list zone:read refresh api-token:syncable"


def create_token(*, secret: str, data: dict, expire: datetime, hours: int = 24):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(hours=hours)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, secret, algorithm="HS256")
    return str(encoded_jwt.decode())


if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "-S",
        "--secret",
        action="store",
        type=str,
        help=f"api secret (alternative use API_SECRET environemnt variable)",
    )
    parser.add_argument(
        "-u", "--user-id", action="store", default=1, type=str, help="user id (sub)"
    )
    parser.add_argument(
        "-s",
        "--scope",
        action="append",
        type=str,
        help=f"scopes (default: {NODE_SCOPES})",
    )
    parser.add_argument(
        "-d", "--days", action="store", default=30, type=int, help="days valid for"
    )
    parser.add_argument(
        "-n",
        "--server-name",
        action="store",
        type=str,
        help="dns/http server name (aaa-bbb-ccc)",
    )
    parser.add_argument(
        "-e",
        "--exportformat",
        action="store_true",
        help="prints the commands to export HTTP_API_SECRET and DNS_API_SECRET",
    )
    args = parser.parse_args()
    scopes = " ".join(args.scope) if len(args.scope or []) > 0 else NODE_SCOPES
    server_name = args.server_name or uuid.uuid4().hex
    expires_delta = timedelta(days=args.days)
    expires_at = datetime.utcnow() + expires_delta
    secret = args.secret or environ.get("API_SECRET")
    if not secret:
        print(
            "No secret provided using -S/--secret or API_SECRET. Please provide one that matches the server and try again"
        )
        sys.exit(1)

    token = create_token(
        secret=secret,
        data={
            "sub": args.user_id,
            "scopes": scopes,
            "dns_server_name": server_name,
            "http_server_name": server_name,
        },
        expire=expires_at,
    )
    if args.exportformat:
        print(f"export HTTP_API_TOKEN={str(token)}")
        print(f"export DNS_API_TOKEN={str(token)}")

    else:
        print("TOKEN:{}".format(str(token)))
