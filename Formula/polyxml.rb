class Polyxml < Formula
  desc "High-performance, polyglot native XML data-binding engine"
  homepage "https://github.com/polyxml/PolyXML"
  url "https://github.com/polyxml/PolyXML/archive/refs/tags/v0.34.6.tar.gz"
  sha256 "8fa89c897baccb7d48694c72f1e8f87f943921c24faae9ba78e2e0744d56f5b9"
  license "MIT"
  head "https://github.com/polyxml/PolyXML.git", branch: "main"

  depends_on "cmake" => :build
  depends_on "rust" => :build

  def install
    # 1. Build C-ABI shared library with Cargo
    system "cargo", "build", "--release", "-p", "polyxml-c"

    # 2. Build & Install C++ interface and headers via CMake
    cd "bindings/cpp" do
      system "cmake", "-B", "build", *std_cmake_args
      system "cmake", "--build", "build"
      system "cmake", "--install", "build"
    end

    # 3. Install C headers
    include.install "crates/polyxml-c/include/polyxml.h"

    # 4. Install native dynamic library
    if OS.mac?
      lib.install "target/release/libpolyxml.dylib"
    else
      lib.install "target/release/libpolyxml.so"
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <iostream>
      #include "polyxml.hpp"

      int main() {
        auto schema = polyxml::SchemaBuilder("Root").build();
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-std=c++20", "-I#{include}", "-L#{lib}", "-lpolyxml", "-o", "test"
  end
end
