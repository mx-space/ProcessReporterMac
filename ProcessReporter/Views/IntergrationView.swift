//
//  IntergrationView.swift
//  ProcessReporter
//
//  Created by Innei on 2023/8/12.
//

import SwiftJotai
import SwiftUI

fileprivate enum IntergrationType: Hashable, CaseIterable {
    case api
    case slack

    var systemName: String {
        switch self {
        case .api:
            return "API"
        case .slack:
            return "Slack"
        }
    }

    var customLogoImage: String {
        switch self {
        case .slack:
            return "slack"

        case .api:
            return "terminal"
        }
    }
}

fileprivate struct SidebarButtonView: View {
    @Binding var currentSelectedIntergration: IntergrationType
    var integration: IntergrationType

    var isSelected: Bool {
        return currentSelectedIntergration == integration
    }

    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Image(integration.customLogoImage)
                .resizable() // 使图片可调整大小
                .aspectRatio(contentMode: .fit) // 保持图片的宽高比
                .frame(width: 30, height: 30) // 为图片设置尺寸

            Text(integration.systemName)
                .font(.body)
                .bold()
                .fixedSize()
            Spacer().frame(minWidth: 0)
        }
        .padding()
        .buttonStyle(BorderlessButtonStyle())
        .background(isSelected ? .blue : .clear)
        .foregroundColor(isSelected ? .white : .primary)
        .cornerRadius(6)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle()) // 确保整个区域是可点击的

        .onTapGesture {
            currentSelectedIntergration = integration
            action?()
        }
    }
}

struct IntergrationView: View {
    @State fileprivate var currentSelectedIntergration = IntergrationType.api

    var body: some View {
        HStack {
            VStack(spacing: 0) {
                ScrollView {
                    SidebarButtonView(currentSelectedIntergration: $currentSelectedIntergration, integration: .api)

                    SidebarButtonView(currentSelectedIntergration: $currentSelectedIntergration, integration: .slack)
                }
            }
            .background(.background)
            .frame(width: 120, height: 400)

            VStack {
                ScrollView {
                    Group {
                        if currentSelectedIntergration == .api {
                            ApiIntegrationView()
                        } else if currentSelectedIntergration == .slack {
                            SlackIntegrationView()
                        }
                    }.padding(.vertical, 12)

                    Spacer()
                }
            }.padding()
        }
    }
}

struct IntergrationView_Previews: PreviewProvider {
    static var previews: some View {
        IntergrationView()
    }
}
