//
//  IntergrationView.swift
//  ProcessReporter
//
//  Created by Innei on 2023/8/12.
//

import SwiftJotai
import SwiftUI

struct SidebarButtonView: View {
    var action: () -> Void
    var systemName: String
    var buttonText: String

    var isSelected: Bool

    var body: some View {
        HStack {
            Image(systemName: systemName)
           
            Text(buttonText)
                .font(.body)
                .bold()
                .fixedSize()
            Spacer().frame(minWidth: 0)
        }
        .padding()
        .buttonStyle(BorderlessButtonStyle())
        .background(isSelected ? .blue : .clear)
        .cornerRadius(6)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle()) // 确保整个区域是可点击的

        .onTapGesture {
            action()
        }
    }
}

struct IntergrationView: View {
    @StateObject var apiKey = AtomValue(Atoms.apiKeyAtom)
    @StateObject var endpoint = AtomValue(Atoms.endpointAtom)
    
    @StateObject var slackApiToken = AtomValue(Atoms.slackApiTokenAtom)

    enum IntergrationType: Hashable, CaseIterable {
        case api
        case slack
    }

    @State var currentSelectedIntergration = IntergrationType.api

    var body: some View {
        HStack {
            VStack(spacing: 0) {
                ScrollView {
                    SidebarButtonView(action: {
                                          currentSelectedIntergration = IntergrationType.api
                                      },
                                      systemName: "arrowtriangle.up",
                                      buttonText: "API Report",
                                      isSelected: currentSelectedIntergration == IntergrationType.api
                    )

                    SidebarButtonView(action: {
                                          currentSelectedIntergration = IntergrationType.slack
                                      },
                                      systemName: "arrowtriangle.up",
                                      buttonText: "Slack",
                                      isSelected: currentSelectedIntergration == IntergrationType.slack
                    )
                }
            }
            .background(.green)
            .frame(width: 120, height: 400)

            HStack(alignment: .top) {
                if currentSelectedIntergration == .api {
                    Form {
                        SecureField("API Key", text: apiKey.binding)
                        TextField("Endpoint", text: endpoint.binding)
                    }
                } else if currentSelectedIntergration == .slack {
                    Form {
                        TextField("Slack API Token", text: slackApiToken.binding)
                    }
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
