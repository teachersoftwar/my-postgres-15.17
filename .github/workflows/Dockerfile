# مرحله 1: محیط کامپایل (Builder)
FROM ubuntu:22.04 AS builder

# جلوگیری از نمایش سوالات حین نصب پکیج‌ها
ENV DEBIAN_FRONTEND=noninteractive

# نصب ابزارهای پیش‌نیاز برای کامپایل
RUN apt-get update && apt-get install -y \
    build-essential \
    libreadline-dev \
    zlib1g-dev \
    libicu-dev \
    bison \
    flex \
    pkg-config \
    wget \
    && rm -rf /var/lib/apt/lists/*

# تنظیم متغیر نسخه برای استفاده در ادامه (مقدار را با فایل خودتان تطابق دهید)
ENV PG_VERSION=15.17

# کپی کردن فایل سورس (که شما از پیش دانلود کردید) به داخل کانتینر
# اسم فایل را با فایل خودتان تطابق دهید - باید دقیقاً در مسیر /tmp باشد
COPY postgresql-${PG_VERSION}.tar.gz /tmp/

# وارد شدن به مسیر موقت و خارج کردن فایل از حالت فشرده
WORKDIR /tmp
RUN tar -xzf postgresql-${PG_VERSION}.tar.gz && \
    rm postgresql-${PG_VERSION}.tar.gz

# پیکربندی و ساخت (کامپایل) PostgreSQL
WORKDIR /tmp/postgresql-${PG_VERSION}
RUN ./configure --prefix=/usr/local/postgresql-${PG_VERSION} \
                --with-icu \
                --with-openssl
RUN make -j$(nproc) world
RUN make install-world

# مرحله 2: ایمیج نهایی (Final Image)
FROM ubuntu:22.04

# نصب حداقل پیش‌نیازهای مورد نیاز برای اجرای PostgreSQL
RUN apt-get update && apt-get install -y \
    libreadline8 \
    libicu70 \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

# کپی کردن فایل‌های ساخته شده در مرحله اول (builder) به ایمیج نهایی
COPY --from=builder /usr/local/postgresql-15.17 /usr/local/postgresql
COPY --from=builder /usr/local/postgresql-15.17/bin /usr/local/bin

# ایجاد کاربر و پوشه مخصوص PostgreSQL
RUN groupadd -r postgres --gid=999 && \
    useradd -r -g postgres --uid=999 -m -d /var/lib/postgresql postgres && \
    mkdir -p /var/run/postgresql && \
    chown -R postgres:postgres /var/run/postgresql

ENV PATH=/usr/local/bin:$PATH
ENV PGDATA=/var/lib/postgresql/data

# کپی کردن اسکریپت ورودی برای مدیریت فرآیندها
RUN mkdir -p /docker-entrypoint-initdb.d
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# پورت پیش‌فرض PostgreSQL
EXPOSE 5432
CMD ["postgres"]
