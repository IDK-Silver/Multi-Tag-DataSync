#include "mainwindow.h"
#include <QMenu>
#include <QAction>
#include <QIcon>
#include <QMessageBox>
#include <QApplication>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent), trayIcon(new QSystemTrayIcon(this))
{
    setWindowTitle("托盤應用程式");
    resize(400, 300);

    // 設定托盤圖標
    trayIcon->setIcon(QIcon(":/icons/tray_icon.png"));
    trayIcon->setToolTip("點擊顯示/隱藏應用程式");

    // 建立右鍵選單
    QMenu *menu = new QMenu(this);
    QAction *quitAction = new QAction("退出", this);
    connect(quitAction, &QAction::triggered, qApp, &QApplication::quit);
    menu->addAction(quitAction);
    trayIcon->setContextMenu(menu);

    // 連接信號
    connect(trayIcon, &QSystemTrayIcon::activated, this, &MainWindow::iconActivated);

    trayIcon->show();
}

MainWindow::~MainWindow()
{
}

void MainWindow::iconActivated(QSystemTrayIcon::ActivationReason reason)
{
    if (reason == QSystemTrayIcon::Trigger) { // 單擊
        toggleVisibility();
    }
}

void MainWindow::toggleVisibility()
{
    if (isVisible()) {
        hide();
    } else {
        show();
        activateWindow();
    }
}
