#include <QApplication>
#include <QMessageBox>
#include "mainwindow.h"

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    // 確保應用程式有系統托盤支持
    if (!QSystemTrayIcon::isSystemTrayAvailable()) {
        QMessageBox::critical(nullptr, "錯誤", "系統不支援系統托盤");
        return -1;
    }
    QApplication::setQuitOnLastWindowClosed(false);

    MainWindow w;
    w.show();

    return a.exec();
}
