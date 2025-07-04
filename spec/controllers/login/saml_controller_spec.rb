# frozen_string_literal: true

#
# Copyright (C) 2015 - present Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

require_relative "../../spec_helper"

describe Login::SamlController do
  before do
    skip("requires SAML extension") unless AuthenticationProvider::SAML.enabled?
  end

  let(:saml_response_fixture) do
    <<~BASE64
      PHNhbWxwOlJlc3BvbnNlIHhtbG5zOnNhbWxwPSJ1cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6cHJv
      dG9jb2wiIHhtbG5zOnNhbWw9InVybjpvYXNpczpuYW1lczp0YzpTQU1MOjIuMDphc3NlcnRpb24iIElE
      PSJfMzJmMTBlOGU0NjVmY2VmNzIzNjhlMjIwZmFlYjgxZGI0YzcyZjBjNjg3IiBWZXJzaW9uPSIyLjAi
      IElzc3VlSW5zdGFudD0iMjAxMi0wOC0wM1QyMDowNzoxNVoiIERlc3RpbmF0aW9uPSJodHRwOi8vc2hh
      cmQxLmxvY2FsZG9tYWluOjMwMDAvc2FtbF9jb25zdW1lIiBJblJlc3BvbnNlVG89ImQwMDE2ZWM4NThk
      OTIzNjBjNTk3YTAxZDE1NTk0NGY4ZGY4ZmRiMTE2ZCI+PHNhbWw6SXNzdWVyPmh0dHA6Ly9waHBzaXRl
      L3NpbXBsZXNhbWwvc2FtbDIvaWRwL21ldGFkYXRhLnBocDwvc2FtbDpJc3N1ZXI+PGRzOlNpZ25hdHVy
      ZSB4bWxuczpkcz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC8wOS94bWxkc2lnIyI+CiAgPGRzOlNpZ25l
      ZEluZm8+PGRzOkNhbm9uaWNhbGl6YXRpb25NZXRob2QgQWxnb3JpdGhtPSJodHRwOi8vd3d3LnczLm9y
      Zy8yMDAxLzEwL3htbC1leGMtYzE0biMiLz4KICAgIDxkczpTaWduYXR1cmVNZXRob2QgQWxnb3JpdGht
      PSJodHRwOi8vd3d3LnczLm9yZy8yMDAwLzA5L3htbGRzaWcjcnNhLXNoYTEiLz4KICA8ZHM6UmVmZXJl
      bmNlIFVSST0iI18zMmYxMGU4ZTQ2NWZjZWY3MjM2OGUyMjBmYWViODFkYjRjNzJmMGM2ODciPjxkczpU
      cmFuc2Zvcm1zPjxkczpUcmFuc2Zvcm0gQWxnb3JpdGhtPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwLzA5
      L3htbGRzaWcjZW52ZWxvcGVkLXNpZ25hdHVyZSIvPjxkczpUcmFuc2Zvcm0gQWxnb3JpdGhtPSJodHRw
      Oi8vd3d3LnczLm9yZy8yMDAxLzEwL3htbC1leGMtYzE0biMiLz48L2RzOlRyYW5zZm9ybXM+PGRzOkRp
      Z2VzdE1ldGhvZCBBbGdvcml0aG09Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvMDkveG1sZHNpZyNzaGEx
      Ii8+PGRzOkRpZ2VzdFZhbHVlPlM2TmUxMW5CN2cxT3lRQUdZckZFT251NVFBUT08L2RzOkRpZ2VzdFZh
      bHVlPjwvZHM6UmVmZXJlbmNlPjwvZHM6U2lnbmVkSW5mbz48ZHM6U2lnbmF0dXJlVmFsdWU+bWdxWlVp
      QTNtYXRyajZaeTREbCsxZ2hzZ29PbDh3UEgybXJGTTlQQXFyWUIwc2t1SlVaaFlVa0NlZ0ViRVg5V1JP
      RWhvWjJiZ3dKUXFlVVB5WDdsZU1QZTdTU2RVRE5LZjlraXV2cGNDWVpzMWxGU0VkNTFFYzhmK0h2ZWpt
      SFVKQVUrSklSV3BwMVZrWVVaQVRpaHdqR0xvazNOR2kveWdvYWpOaDQydlo0PTwvZHM6U2lnbmF0dXJl
      VmFsdWU+CjxkczpLZXlJbmZvPjxkczpYNTA5RGF0YT48ZHM6WDUwOUNlcnRpZmljYXRlPk1JSUNnVEND
      QWVvQ0NRQ2JPbHJXRGRYN0ZUQU5CZ2txaGtpRzl3MEJBUVVGQURDQmhERUxNQWtHQTFVRUJoTUNUazh4
      R0RBV0JnTlZCQWdURDBGdVpISmxZWE1nVTI5c1ltVnlaekVNTUFvR0ExVUVCeE1EUm05dk1SQXdEZ1lE
      VlFRS0V3ZFZUa2xPUlZSVU1SZ3dGZ1lEVlFRREV3OW1aV2xrWlM1bGNteGhibWN1Ym04eElUQWZCZ2tx
      aGtpRzl3MEJDUUVXRW1GdVpISmxZWE5BZFc1cGJtVjBkQzV1YnpBZUZ3MHdOekEyTVRVeE1qQXhNelZh
      Rncwd056QTRNVFF4TWpBeE16VmFNSUdFTVFzd0NRWURWUVFHRXdKT1R6RVlNQllHQTFVRUNCTVBRVzVr
      Y21WaGN5QlRiMnhpWlhKbk1Rd3dDZ1lEVlFRSEV3TkdiMjh4RURBT0JnTlZCQW9UQjFWT1NVNUZWRlF4
      R0RBV0JnTlZCQU1URDJabGFXUmxMbVZ5YkdGdVp5NXViekVoTUI4R0NTcUdTSWIzRFFFSkFSWVNZVzVr
      Y21WaGMwQjFibWx1WlhSMExtNXZNSUdmTUEwR0NTcUdTSWIzRFFFQkFRVUFBNEdOQURDQmlRS0JnUURp
      dmJoUjdQNTE2eC9TM0JxS3h1cFFlMExPTm9saXVwaUJPZXNDTzNTSGJEcmwzK3E5SWJmbmZtRTA0ck51
      TWNQc0l4QjE2MVRkRHBJZXNMQ243YzhhUEhJU0tPdFBsQWVUWlNuYjhRQXU3YVJqWnEzK1BiclA1dVcz
      VGNmQ0dQdEtUeXRIT2dlL09sSmJvMDc4ZFZoWFExNGQxRUR3WEpXMXJSWHVVdDRDOFFJREFRQUJNQTBH
      Q1NxR1NJYjNEUUVCQlFVQUE0R0JBQ0RWZnA4NkhPYnFZK2U4QlVvV1E5K1ZNUXgxQVNEb2hCandPc2cy
      V3lrVXFSWEYrZExmY1VIOWRXUjYzQ3RaSUtGRGJTdE5vbVBuUXo3bmJLK29ueWd3QnNwVkVibkh1VWlo
      WnEzWlVkbXVtUXFDdzRVdnMvMVV2cTNvck9vL1dKVmhUeXZMZ0ZWSzJRYXJRNC82N09aZkhkN1IrUE9C
      WGhvcGhTTXYxWk9vPC9kczpYNTA5Q2VydGlmaWNhdGU+PC9kczpYNTA5RGF0YT48L2RzOktleUluZm8+
      PC9kczpTaWduYXR1cmU+PHNhbWxwOlN0YXR1cz48c2FtbHA6U3RhdHVzQ29kZSBWYWx1ZT0idXJuOm9h
      c2lzOm5hbWVzOnRjOlNBTUw6Mi4wOnN0YXR1czpTdWNjZXNzIi8+PC9zYW1scDpTdGF0dXM+PHNhbWw6
      QXNzZXJ0aW9uIHhtbG5zOnhzaT0iaHR0cDovL3d3dy53My5vcmcvMjAwMS9YTUxTY2hlbWEtaW5zdGFu
      Y2UiIHhtbG5zOnhzPSJodHRwOi8vd3d3LnczLm9yZy8yMDAxL1hNTFNjaGVtYSIgSUQ9Il82MjEyYjdl
      OGMwNjlkMGY5NDhjODY0ODk5MWQzNTdhZGRjNDA5NWE4MmYiIFZlcnNpb249IjIuMCIgSXNzdWVJbnN0
      YW50PSIyMDEyLTA4LTAzVDIwOjA3OjE1WiI+PHNhbWw6SXNzdWVyPmh0dHA6Ly9waHBzaXRlL3NpbXBs
      ZXNhbWwvc2FtbDIvaWRwL21ldGFkYXRhLnBocDwvc2FtbDpJc3N1ZXI+PGRzOlNpZ25hdHVyZSB4bWxu
      czpkcz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC8wOS94bWxkc2lnIyI+CiAgPGRzOlNpZ25lZEluZm8+
      PGRzOkNhbm9uaWNhbGl6YXRpb25NZXRob2QgQWxnb3JpdGhtPSJodHRwOi8vd3d3LnczLm9yZy8yMDAx
      LzEwL3htbC1leGMtYzE0biMiLz4KICAgIDxkczpTaWduYXR1cmVNZXRob2QgQWxnb3JpdGhtPSJodHRw
      Oi8vd3d3LnczLm9yZy8yMDAwLzA5L3htbGRzaWcjcnNhLXNoYTEiLz4KICA8ZHM6UmVmZXJlbmNlIFVS
      ST0iI182MjEyYjdlOGMwNjlkMGY5NDhjODY0ODk5MWQzNTdhZGRjNDA5NWE4MmYiPjxkczpUcmFuc2Zv
      cm1zPjxkczpUcmFuc2Zvcm0gQWxnb3JpdGhtPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwLzA5L3htbGRz
      aWcjZW52ZWxvcGVkLXNpZ25hdHVyZSIvPjxkczpUcmFuc2Zvcm0gQWxnb3JpdGhtPSJodHRwOi8vd3d3
      LnczLm9yZy8yMDAxLzEwL3htbC1leGMtYzE0biMiLz48L2RzOlRyYW5zZm9ybXM+PGRzOkRpZ2VzdE1l
      dGhvZCBBbGdvcml0aG09Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvMDkveG1sZHNpZyNzaGExIi8+PGRz
      OkRpZ2VzdFZhbHVlPmthWk4xK21vUzMyOHByMnpuOFNLVU1MMUVsST08L2RzOkRpZ2VzdFZhbHVlPjwv
      ZHM6UmVmZXJlbmNlPjwvZHM6U2lnbmVkSW5mbz48ZHM6U2lnbmF0dXJlVmFsdWU+MWtVRWtHMzNaR1FN
      Zi8xSDFnenFCT2hUNU4ySTM1dk0wNEpwNjd4VmpuWlhGNTRBcVBxMVphTStXamd4KytBakViTDdrc2FZ
      dU0zSlN5SzdHbFo3N1ZtenBMc01xbjRlTTAwSzdZK0NlWnk1TEIyNHZjbmdYUHhCazZCZFVZa1ZrMHZP
      c1VmQUFaK21SWC96ekJXN1o0QzdxYmpOR2hBQUpnaTEzSm9CV3BVPTwvZHM6U2lnbmF0dXJlVmFsdWU+
      CjxkczpLZXlJbmZvPjxkczpYNTA5RGF0YT48ZHM6WDUwOUNlcnRpZmljYXRlPk1JSUNnVENDQWVvQ0NR
      Q2JPbHJXRGRYN0ZUQU5CZ2txaGtpRzl3MEJBUVVGQURDQmhERUxNQWtHQTFVRUJoTUNUazh4R0RBV0Jn
      TlZCQWdURDBGdVpISmxZWE1nVTI5c1ltVnlaekVNTUFvR0ExVUVCeE1EUm05dk1SQXdEZ1lEVlFRS0V3
      ZFZUa2xPUlZSVU1SZ3dGZ1lEVlFRREV3OW1aV2xrWlM1bGNteGhibWN1Ym04eElUQWZCZ2txaGtpRzl3
      MEJDUUVXRW1GdVpISmxZWE5BZFc1cGJtVjBkQzV1YnpBZUZ3MHdOekEyTVRVeE1qQXhNelZhRncwd056
      QTRNVFF4TWpBeE16VmFNSUdFTVFzd0NRWURWUVFHRXdKT1R6RVlNQllHQTFVRUNCTVBRVzVrY21WaGN5
      QlRiMnhpWlhKbk1Rd3dDZ1lEVlFRSEV3TkdiMjh4RURBT0JnTlZCQW9UQjFWT1NVNUZWRlF4R0RBV0Jn
      TlZCQU1URDJabGFXUmxMbVZ5YkdGdVp5NXViekVoTUI4R0NTcUdTSWIzRFFFSkFSWVNZVzVrY21WaGMw
      QjFibWx1WlhSMExtNXZNSUdmTUEwR0NTcUdTSWIzRFFFQkFRVUFBNEdOQURDQmlRS0JnUURpdmJoUjdQ
      NTE2eC9TM0JxS3h1cFFlMExPTm9saXVwaUJPZXNDTzNTSGJEcmwzK3E5SWJmbmZtRTA0ck51TWNQc0l4
      QjE2MVRkRHBJZXNMQ243YzhhUEhJU0tPdFBsQWVUWlNuYjhRQXU3YVJqWnEzK1BiclA1dVczVGNmQ0dQ
      dEtUeXRIT2dlL09sSmJvMDc4ZFZoWFExNGQxRUR3WEpXMXJSWHVVdDRDOFFJREFRQUJNQTBHQ1NxR1NJ
      YjNEUUVCQlFVQUE0R0JBQ0RWZnA4NkhPYnFZK2U4QlVvV1E5K1ZNUXgxQVNEb2hCandPc2cyV3lrVXFS
      WEYrZExmY1VIOWRXUjYzQ3RaSUtGRGJTdE5vbVBuUXo3bmJLK29ueWd3QnNwVkVibkh1VWloWnEzWlVk
      bXVtUXFDdzRVdnMvMVV2cTNvck9vL1dKVmhUeXZMZ0ZWSzJRYXJRNC82N09aZkhkN1IrUE9CWGhvcGhT
      TXYxWk9vPC9kczpYNTA5Q2VydGlmaWNhdGU+PC9kczpYNTA5RGF0YT48L2RzOktleUluZm8+PC9kczpT
      aWduYXR1cmU+PHNhbWw6U3ViamVjdD48c2FtbDpOYW1lSUQgU1BOYW1lUXVhbGlmaWVyPSJodHRwOi8v
      c2hhcmQxLmxvY2FsZG9tYWluL3NhbWwyIiBGb3JtYXQ9InVybjpvYXNpczpuYW1lczp0YzpTQU1MOjIu
      MDpuYW1laWQtZm9ybWF0OnRyYW5zaWVudCI+XzNiM2U3NzE0YjcyZTI5ZGM0MjkwMzIxYTA3NWZhMGI3
      MzMzM2E0ZjI1Zjwvc2FtbDpOYW1lSUQ+PHNhbWw6U3ViamVjdENvbmZpcm1hdGlvbiBNZXRob2Q9InVy
      bjpvYXNpczpuYW1lczp0YzpTQU1MOjIuMDpjbTpiZWFyZXIiPjxzYW1sOlN1YmplY3RDb25maXJtYXRp
      b25EYXRhIE5vdE9uT3JBZnRlcj0iMjAxMi0wOC0wM1QyMDoxMjoxNVoiIFJlY2lwaWVudD0iaHR0cDov
      L3NoYXJkMS5sb2NhbGRvbWFpbjozMDAwL3NhbWxfY29uc3VtZSIgSW5SZXNwb25zZVRvPSJkMDAxNmVj
      ODU4ZDkyMzYwYzU5N2EwMWQxNTU5NDRmOGRmOGZkYjExNmQiLz48L3NhbWw6U3ViamVjdENvbmZpcm1h
      dGlvbj48L3NhbWw6U3ViamVjdD48c2FtbDpDb25kaXRpb25zIE5vdEJlZm9yZT0iMjAxMi0wOC0wM1Qy
      MDowNjo0NVoiIE5vdE9uT3JBZnRlcj0iMjAxMi0wOC0wM1QyMDoxMjoxNVoiPjxzYW1sOkF1ZGllbmNl
      UmVzdHJpY3Rpb24+PHNhbWw6QXVkaWVuY2U+aHR0cDovL3NoYXJkMS5sb2NhbGRvbWFpbi9zYW1sMjwv
      c2FtbDpBdWRpZW5jZT48L3NhbWw6QXVkaWVuY2VSZXN0cmljdGlvbj48L3NhbWw6Q29uZGl0aW9ucz48
      c2FtbDpBdXRoblN0YXRlbWVudCBBdXRobkluc3RhbnQ9IjIwMTItMDgtMDNUMjA6MDc6MTVaIiBTZXNz
      aW9uTm90T25PckFmdGVyPSIyMDEyLTA4LTA0VDA0OjA3OjE1WiIgU2Vzc2lvbkluZGV4PSJfMDJmMjZh
      ZjMwYTM3YWZiOTIwODFmM2E3MzcyODgxMDE5M2VmZDdmYTZlIj48c2FtbDpBdXRobkNvbnRleHQ+PHNh
      bWw6QXV0aG5Db250ZXh0Q2xhc3NSZWY+dXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOmFjOmNsYXNz
      ZXM6UGFzc3dvcmQ8L3NhbWw6QXV0aG5Db250ZXh0Q2xhc3NSZWY+PC9zYW1sOkF1dGhuQ29udGV4dD48
      L3NhbWw6QXV0aG5TdGF0ZW1lbnQ+PHNhbWw6QXR0cmlidXRlU3RhdGVtZW50PjxzYW1sOkF0dHJpYnV0
      ZSBOYW1lPSJ1cm46b2lkOjEuMy42LjEuNC4xLjU5MjMuMS4xLjEuMSIgTmFtZUZvcm1hdD0idXJuOm9h
      c2lzOm5hbWVzOnRjOlNBTUw6Mi4wOmF0dHJuYW1lLWZvcm1hdDp1cmkiPjxzYW1sOkF0dHJpYnV0ZVZh
      bHVlIHhzaTp0eXBlPSJ4czpzdHJpbmciPm1lbWJlcjwvc2FtbDpBdHRyaWJ1dGVWYWx1ZT48L3NhbWw6
      QXR0cmlidXRlPjxzYW1sOkF0dHJpYnV0ZSBOYW1lPSJ1cm46b2lkOjEuMy42LjEuNC4xLjU5MjMuMS4x
      LjEuNiIgTmFtZUZvcm1hdD0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOmF0dHJuYW1lLWZvcm1h
      dDp1cmkiPjxzYW1sOkF0dHJpYnV0ZVZhbHVlIHhzaTp0eXBlPSJ4czpzdHJpbmciPnN0dWRlbnRAZXhh
      bXBsZS5lZHU8L3NhbWw6QXR0cmlidXRlVmFsdWU+PC9zYW1sOkF0dHJpYnV0ZT48L3NhbWw6QXR0cmli
      dXRlU3RhdGVtZW50Pjwvc2FtbDpBc3NlcnRpb24+PC9zYW1scDpSZXNwb25zZT4=
    BASE64
  end

  describe "#new" do
    let(:account) { account_with_saml(saml_log_in_url: "https://example.com/saml/login") }

    before do
      controller.request.env["canvas.domain_root_account"] = account
    end

    it "includes ForceAuthn if force_login is set" do
      get :new, params: { force_login: true }
      expect(response).to be_redirect

      authn_request, = SAML2::Bindings::HTTPRedirect.decode(response.location)

      expect(authn_request).to be_a(SAML2::AuthnRequest)
      expect(authn_request.force_authn?).to be true
    end

    it "includes ForceAuthn if recently logged out" do
      session[:just_logged_out] = Time.now.utc
      get :new
      expect(response).to be_redirect

      authn_request, = SAML2::Bindings::HTTPRedirect.decode(response.location)
      expect(authn_request).to be_a(SAML2::AuthnRequest)
      expect(authn_request.force_authn?).to be true
    end

    it "does not include ForceAuthn otherwise" do
      get :new
      expect(response).to be_redirect

      authn_request, = SAML2::Bindings::HTTPRedirect.decode(response.location)
      expect(authn_request).to be_a(SAML2::AuthnRequest)
      expect(authn_request.force_authn?).to be_nil
    end
  end

  it "scopes logins to the correct domain root account" do
    unique_id = "foo@example.com"

    account1 = account_with_saml
    user1 = user_with_pseudonym({ active_all: true, username: unique_id })
    @pseudonym.account = account1
    @pseudonym.save!

    account2 = account_with_saml
    user2 = user_with_pseudonym({ active_all: true, username: unique_id })
    @pseudonym.account = account2
    @pseudonym.save!

    response = SAML2::Response.new
    response.issuer = SAML2::NameID.new("saml_entity")
    response.assertions << (assertion = SAML2::Assertion.new)
    assertion.subject = SAML2::Subject.new
    assertion.subject.name_id = SAML2::NameID.new(unique_id)
    allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
      [response, nil]
    )
    allow_any_instance_of(SAML2::Entity).to receive(:valid_response?)

    controller.request.env["canvas.domain_root_account"] = account1
    session[:sentinel] = true
    post :create, params: { SAMLResponse: "foo" }
    expect(session[:sentinel]).to be_nil
    expect(response).to redirect_to(dashboard_url(login_success: 1))
    expect(session[:saml_unique_id]).to eq unique_id
    expect(Pseudonym.find(session["pseudonym_credentials_id"])).to eq user1.pseudonyms.first
    # the auth provider got set on the pseudonym
    expect(assigns[:current_pseudonym].authentication_provider).to eq account1.authentication_providers.active.find("saml")
    # but not persisted, because the feature flag isn't set
    expect(@pseudonym.reload.authentication_provider).to be_nil

    (controller.instance_variables.grep(/@[^_]/) - ["@mock_proxy"]).each do |var|
      controller.send :remove_instance_variable, var
    end
    session.clear

    controller.request.env["canvas.domain_root_account"] = account2
    post :create, params: { SAMLResponse: "bar" }
    expect(response).to redirect_to(dashboard_url(login_success: 1))
    expect(session[:saml_unique_id]).to eq unique_id
    expect(Pseudonym.find(session["pseudonym_credentials_id"])).to eq user2.pseudonyms.first
  end

  it "enforces a valid entity id" do
    unique_id = "foo@example.com"

    account1 = account_with_saml
    user_with_pseudonym({ active_all: true, username: unique_id })
    @pseudonym.account = account1
    @pseudonym.save!

    saml_response = SAML2::Response.new
    allow(saml_response).to receive_messages(errors: [], issuer: double(id: "such a lie"))
    allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
      [saml_response, nil]
    )
    allow_any_instance_of(SAML2::Entity).to receive(:valid_response?)

    controller.request.env["canvas.domain_root_account"] = account1
    post :create, params: { SAMLResponse: "foo" }
    expect(response).to redirect_to(login_url)
  end

  it "doesn't allow deleted users" do
    account = account_with_saml
    user_with_pseudonym(active_all: 1, account:)
    @user.update!(workflow_state: "deleted")

    response = SAML2::Response.new
    response.issuer = SAML2::NameID.new("saml_entity")
    response.assertions << (assertion = SAML2::Assertion.new)
    assertion.subject = SAML2::Subject.new
    assertion.subject.name_id = SAML2::NameID.new(@pseudonym.unique_id)
    allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
      [response, nil]
    )
    allow_any_instance_of(SAML2::Entity).to receive(:valid_response?)
    allow(LoadAccount).to receive(:default_domain_root_account).and_return(account)

    post :create, params: { SAMLResponse: "foo" }
    expect(response).to redirect_to(login_url)
  end

  it "wont support logout via login endpoint" do
    allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
      [SAML2::LogoutRequest.new, nil]
    )
    post :create, params: { SAMLResponse: "foo" }
    expect(response.status.to_i).to eq(400)
  end

  it "searches for assertion issuer" do
    unique_id = "foo@example.com"

    account1 = account_with_saml
    user_with_pseudonym({ active_all: true, username: unique_id })
    @pseudonym.account = account1
    @pseudonym.save!

    saml_response = SAML2::Response.new
    allow(saml_response).to receive_messages(errors: [], issuer: nil, assertions: [double(issuer: double(id: "such a lie"))])
    allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
      [saml_response, nil]
    )
    allow_any_instance_of(SAML2::Entity).to receive(:valid_response?)

    controller.request.env["canvas.domain_root_account"] = account1
    post :create, params: { SAMLResponse: "foo" }
    expect(response).to redirect_to(login_url)
  end

  it "redirects when a user is authenticated but is not found in canvas" do
    unique_id = "foo@example.com"

    account = account_with_saml

    response = SAML2::Response.new
    response.issuer = SAML2::NameID.new("saml_entity")
    response.assertions << (assertion = SAML2::Assertion.new)
    assertion.subject = SAML2::Subject.new
    assertion.subject.name_id = SAML2::NameID.new(unique_id)
    allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
      [response, nil]
    )
    allow_any_instance_of(SAML2::Entity).to receive(:valid_response?)

    # We dont want to log them out of everything.
    expect(controller).not_to receive(:logout_user_action)
    controller.request.env["canvas.domain_root_account"] = account

    # Default to Login url if set to nil or blank
    post :create, params: { SAMLResponse: "foo" }
    expect(response).to redirect_to(login_url)
    expect(flash[:delegated_message]).to_not be_nil
    expect(session[:saml_unique_id]).to be_nil

    account.unknown_user_url = ""
    account.save!
    controller.instance_variable_set(:@aac, nil)
    post :create, params: { SAMLResponse: "foo" }
    expect(response).to redirect_to(login_url)
    expect(flash[:delegated_message]).to_not be_nil
    expect(session[:saml_unique_id]).to be_nil

    # Redirect to a specifiec url
    unknown_user_url = "https://example.com/unknown_user"
    account.unknown_user_url = unknown_user_url
    account.save!
    controller.instance_variable_set(:@aac, nil)
    post :create, params: { SAMLResponse: "foo" }
    expect(response).to redirect_to(/^#{unknown_user_url}\?message=Canvas/)
    expect(session[:saml_unique_id]).to be_nil
  end

  it "creates an unfound user when JIT provisioning is enabled" do
    unique_id = "foo@example.com"

    account = account_with_saml
    ap = account.authentication_providers.first
    ap.update_attribute(:jit_provisioning, true)
    ap.federated_attributes = { "display_name" => "eduPersonNickname" }
    ap.save!

    response = SAML2::Response.new
    response.issuer = SAML2::NameID.new("saml_entity")
    response.assertions << (assertion = SAML2::Assertion.new)
    assertion.subject = SAML2::Subject.new
    assertion.subject.name_id = SAML2::NameID.new(unique_id)
    assertion.statements << SAML2::AttributeStatement.new([SAML2::Attribute.create("eduPersonNickname", "Cody Cutrer")])
    allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
      [response, nil]
    )
    allow_any_instance_of(SAML2::Entity).to receive(:valid_response?)

    # We dont want to log them out of everything.
    expect(controller).not_to receive(:logout_user_action)
    controller.request.env["canvas.domain_root_account"] = account

    expect(account.pseudonyms.active.by_unique_id(unique_id)).to_not be_exists
    # Default to Login url if set to nil or blank
    post :create, params: { SAMLResponse: "foo" }
    expect(response).to redirect_to(dashboard_url(login_success: 1))
    p = account.pseudonyms.active.by_unique_id(unique_id).first!
    expect(p.authentication_provider).to eq ap
    expect(p.user.short_name).to eq "Cody Cutrer"
  end

  it "skips JIT user provisioning for suspended pseudonyms" do
    account = account_with_saml
    user = user_with_pseudonym(active_all: 1, account:)
    user.pseudonyms.last.update!(workflow_state: "suspended")

    ap = account.authentication_providers.first
    ap.update_attribute(:jit_provisioning, true)
    ap.federated_attributes = { "sis_user_id" => "urn:oid" }
    ap.save!

    response = SAML2::Response.new
    response.issuer = SAML2::NameID.new("saml_entity")
    response.assertions << (assertion = SAML2::Assertion.new)
    assertion.subject = SAML2::Subject.new
    assertion.subject.name_id = SAML2::NameID.new(@pseudonym.unique_id)
    assertion.statements << SAML2::AttributeStatement.new(
      [SAML2::Attribute.create("urn:oid", "some_unique_id")]
    )
    allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
      [response, nil]
    )
    allow_any_instance_of(SAML2::Entity).to receive(:valid_response?)
    allow(LoadAccount).to receive(:default_domain_root_account).and_return(account)

    post :create, params: { SAMLResponse: "foo" }
    expect(response).to redirect_to(login_url)
    expect(flash[:delegated_message]).to_not be_nil
    expect(session[:saml_unique_id]).to be_nil
  end

  it "updates federated attributes" do
    account = account_with_saml
    user_with_pseudonym(active_all: 1, account:)

    ap = account.authentication_providers.first
    ap.federated_attributes = { "display_name" => "eduPersonNickname" }
    ap.save!

    response = SAML2::Response.new
    response.issuer = SAML2::NameID.new("saml_entity")
    response.assertions << (assertion = SAML2::Assertion.new)
    assertion.subject = SAML2::Subject.new
    assertion.subject.name_id = SAML2::NameID.new(@pseudonym.unique_id)
    assertion.statements << SAML2::AttributeStatement.new([SAML2::Attribute.create("eduPersonNickname", "Cody Cutrer")])
    allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
      [response, nil]
    )
    allow_any_instance_of(SAML2::Entity).to receive(:valid_response?)
    allow(LoadAccount).to receive(:default_domain_root_account).and_return(account)

    post :create, params: { SAMLResponse: "foo" }
    expect(response).to redirect_to(dashboard_url(login_success: 1))
    expect(@user.reload.short_name).to eq "Cody Cutrer"
  end

  it "handles student logout for parent registration" do
    unique_id = "foo@example.com"

    account1 = account_with_saml(
      parent_registration: true,
      saml_log_out_url: "http://example.com/logout"
    )
    user_with_pseudonym({ active_all: true, username: unique_id })
    @pseudonym.account = account1
    @pseudonym.save!

    saml_response = SAML2::Response.new
    saml_response.issuer = SAML2::NameID.new("saml_entity")
    saml_response.assertions << (assertion = SAML2::Assertion.new)
    assertion.subject = SAML2::Subject.new
    assertion.subject.name_id = SAML2::NameID.new(unique_id)
    allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
      [saml_response, nil]
    )
    allow_any_instance_of(SAML2::Entity).to receive(:valid_response?)

    controller.request.env["canvas.domain_root_account"] = account1
    session[:parent_registration] = { observee: { unique_id: "foo@example.com" } }
    post :create, params: { SAMLResponse: "foo" }
    expect(response).to be_redirect
    expect(response.location).to match(%r{example.com/logout})
  end

  context "with relay state" do
    before do
      account = account_with_saml
      user_with_pseudonym(active_all: 1, account:)
      allow_any_instance_of(SAML2::Entity).to receive(:valid_response?)
      allow(LoadAccount).to receive(:default_domain_root_account).and_return(account)
      session[:return_to] = "/courses/1"
    end

    let(:saml_response) do
      saml_response = SAML2::Response.new
      saml_response.issuer = SAML2::NameID.new("saml_entity")
      saml_response.assertions << (assertion = SAML2::Assertion.new)
      assertion.subject = SAML2::Subject.new
      assertion.subject.name_id = SAML2::NameID.new(@pseudonym.unique_id)
      assertion.statements << SAML2::AttributeStatement.new([SAML2::Attribute.create("eduPersonNickname", "Cody Cutrer")])
      saml_response
    end

    it "works for the local account" do
      allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
        [saml_response, "http://test.host/courses/2"]
      )

      expect(Account).to receive(:find_by_domain).and_return(@pseudonym.account)

      post :create, params: { SAMLResponse: "foo", RelayState: "http://test.host/courses/2" }
      expect(response).to be_redirect
      expect(response.location).to eql "http://test.host/courses/2"
    end

    it "ignores it if it's going to cause a login loop" do
      allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
        [saml_response, "http://test.host/login/saml"]
      )

      expect(Account).not_to receive(:find_by_domain)

      post :create, params: { SAMLResponse: "foo", RelayState: "http://test.host/login/saml" }
      expect(response).to be_redirect
      expect(response.location).to eql "http://test.host/courses/1"
    end

    it "appends a session token if we're redirecting to a different domain for the same account" do
      allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
        [saml_response, "https://sameaccount/courses/2"]
      )

      expect(Account).to receive(:find_by_domain).and_return(@pseudonym.account)

      post :create, params: { SAMLResponse: "foo", RelayState: "https://sameaccount/courses/2" }
      expect(response).to be_redirect
      expect(response.location).to match(%r{^https://sameaccount/courses/2\?session_token=})
    end

    it "appends a session token if we're redirecting to a trusted account" do
      allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
        [saml_response, "https://otheraccount/courses/1"]
      )

      account2 = double
      expect(Account).to receive(:find_by_domain).and_return(account2)
      expect_any_instantiation_of(@pseudonym).to receive(:works_for_account?).with(account2, true).and_return(true)

      post :create, params: { SAMLResponse: "foo", RelayState: "https://otheraccount/courses/1" }
      expect(response).to be_redirect
      expect(response.location).to match(%r{^https://otheraccount/courses/1\?session_token=})
    end

    it "ignores empty string" do
      allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
        [saml_response, ""]
      )

      post :create, params: { SAMLResponse: "foo", RelayState: "" }
      expect(response).to be_redirect
      expect(response.location).to match(%r{/courses/1$})
    end

    it "ignores relative path" do
      allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
        [saml_response, "None"]
      )

      post :create, params: { SAMLResponse: "foo", RelayState: "None" }
      expect(response).to be_redirect
      expect(response.location).to match(%r{/courses/1$})
    end

    it "ignores non-path URIs" do
      allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
        [saml_response, "https:mem:abc"]
      )

      post :create, params: { SAMLResponse: "foo", RelayState: "https:mem:abc" }
      expect(response).to be_redirect
      expect(response.location).to match(%r{/courses/1$})
    end

    it "ignores non-HTTP" do
      allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
        [saml_response, "javascript:///"]
      )

      post :create, params: { SAMLResponse: "foo", RelayState: "javascript:///" }
      expect(response).to be_redirect
      expect(response.location).to match(%r{/courses/1$})
    end

    it "disallows redirects to non-trusted accounts" do
      allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
        [saml_response, "https://otheraccount/courses/1"]
      )

      expect(Account).to receive(:find_by_domain).and_return(nil)

      post :create, params: { SAMLResponse: "foo", RelayState: "https://otheraccount/courses/1" }
      expect(response).to be_redirect
      expect(response.location).not_to match(/session_token/)
    end
  end

  context "multiple authorization configs" do
    before :once do
      @account = Account.create!
      @unique_id = "foo@example.com"
      @user1 = user_with_pseudonym(active_all: true, username: @unique_id, account: @account)
      @account.authentication_providers.create!(auth_type: "saml", identifier_format: "uid")

      @aac2 = @account.authentication_providers.build(auth_type: "saml")
      @aac2.idp_entity_id = "https://example.com/idp1"
      @aac2.log_in_url = "https://example.com/idp1/sso"
      @aac2.log_out_url = "https://example.com/idp1/slo"
      @aac2.save!
    end

    it "sends the AuthnRequest by entity id" do
      controller.request.env["canvas.domain_root_account"] = @account
      get :new, params: { entityID: "https://example.com/idp1" }
      expect(response).to be_redirect
      expect(response.location).to match(%r{^https://example.com/idp1/sso\?SAMLRequest=})
    end

    it "saml_consumes login with multiple authorization configs" do
      response = SAML2::Response.new
      response.issuer = SAML2::NameID.new(@aac2.idp_entity_id)
      response.assertions << (assertion = SAML2::Assertion.new)
      assertion.subject = SAML2::Subject.new
      assertion.subject.name_id = SAML2::NameID.new(@unique_id)
      allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
        [response, "/courses"]
      )
      allow_any_instance_of(SAML2::Entity).to receive(:valid_response?)

      controller.request.env["canvas.domain_root_account"] = @account
      post :create, params: { SAMLResponse: "foo", RelayState: "/courses" }
      expect(response).to redirect_to(courses_url)
      expect(session[:saml_unique_id]).to eq @unique_id
    end

    it "saml_logouts with multiple authorization configs" do
      logout_response = SAML2::LogoutResponse.new
      logout_response.issuer = SAML2::NameID.new(@aac2.idp_entity_id)
      expect(SAML2::Bindings::HTTPRedirect).to receive(:decode).and_return(logout_response)
      controller.request.env["canvas.domain_root_account"] = @account
      get :destroy, params: { SAMLResponse: "foo", RelayState: "/courses" }

      expect(response).to redirect_to(saml_login_url(@aac2))
    end
  end

  context "multiple SAML configs" do
    before :once do
      @account = account_with_saml(saml_log_in_url: "https://example.com/idp1/sli")
      @unique_id = "foo@example.com"
      @user1 = user_with_pseudonym(active_all: true, username: @unique_id, account: @account)
      @aac1 = @account.authentication_providers.first
      @aac1.idp_entity_id = "https://example.com/idp1"
      @aac1.log_out_url = "https://example.com/idp1/slo"
      @aac1.save!

      @aac2 = @aac1.clone
      @aac2.idp_entity_id = "https://example.com/idp2"
      @aac2.log_in_url = "https://example.com/idp2/sli"
      @aac2.log_out_url = "https://example.com/idp2/slo"
      @aac2.position = nil
      @aac2.save!
    end

    describe "#create" do
      def post_create
        allow_any_instance_of(SAML2::Entity).to receive(:valid_response?)

        controller.request.env["canvas.domain_root_account"] = @account
        post :create, params: { SAMLResponse: "foo", RelayState: "/courses" }
      end

      it "finds the SAML config by entity_id" do
        response = SAML2::Response.new
        response.issuer = SAML2::NameID.new(@aac2.idp_entity_id)
        response.assertions << (assertion = SAML2::Assertion.new)
        assertion.subject = SAML2::Subject.new
        assertion.subject.name_id = SAML2::NameID.new(@unique_id)
        allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
          [response, "/courses"]
        )

        post_create

        expect(response).to redirect_to(courses_url)
        expect(session[:saml_unique_id]).to eq @unique_id
      end

      it "redirects to login screen with message if no AAC found" do
        saml_response = SAML2::Response.new
        allow(saml_response).to receive_messages(errors: [], issuer: double(id: "hahahahahahaha"))
        allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
          [saml_response, nil]
        )

        session[:sentinel] = true
        post_create
        expect(session[:sentinel]).to be true

        expect(response).to redirect_to(login_url)
        expect(flash[:delegated_message]).to eq "Canvas is not configured to receive logins from hahahahahahaha."
      end
    end

    context "/new" do
      def get_new(aac_id = nil)
        controller.request.env["canvas.domain_root_account"] = @account
        if aac_id
          get "new", params: { id: aac_id }
        else
          get "new"
        end
      end

      it "redirects to default login" do
        get_new
        expect(response.location.starts_with?(@aac1.log_in_url)).to be_truthy
      end

      it "uses the specified AAC" do
        get_new(@aac1.id.to_s)
        expect(response.location.starts_with?(@aac1.log_in_url)).to be_truthy
        controller.instance_variable_set(:@aac, nil)
        get_new(@aac2.id.to_s)
        expect(response.location.starts_with?(@aac2.log_in_url)).to be_truthy
      end

      it "reject unknown specified AAC" do
        get_new("0")
        expect(response).to have_http_status :not_found
      end
    end

    context "logging out" do
      before do
        controller.request.env["canvas.domain_root_account"] = @account
        post :create, params: { SAMLResponse: "foo", RelayState: "/courses" }
      end

      describe "#destroy" do
        it "returns bad request if a SAMLResponse or SAMLRequest parameter is not provided" do
          expect(controller).not_to receive(:logout_user_action)
          get :destroy
          expect(response).to have_http_status :bad_request
        end

        it "finds the correct AAC" do
          expect_any_instantiation_of(@aac1).not_to receive(:debugging?)
          expect_any_instantiation_of(@aac2).to receive(:debugging?).at_least(1)

          logout_response = SAML2::LogoutResponse.new
          logout_response.issuer = SAML2::NameID.new(@aac2.idp_entity_id)
          expect(SAML2::Bindings::HTTPRedirect).to receive(:decode).and_return(logout_response)

          controller.request.env["canvas.domain_root_account"] = @account
          get :destroy, params: { SAMLResponse: "foo" }
          expect(response).to redirect_to(saml_login_url(@aac2))
        end

        it "redirects an error response to idp if no user is logged in" do
          logout_request = SAML2::LogoutRequest.new
          logout_request.issuer = SAML2::NameID.new(@aac2.idp_entity_id)
          logout_request.name_id = SAML2::NameID.new("bogus user")
          expect(SAML2::Bindings::HTTPRedirect).to receive(:decode).and_return(logout_request)

          controller.request.env["canvas.domain_root_account"] = @account
          get :destroy, params: { SAMLRequest: "foo" }

          expect(response).to be_redirect
          expect(response.location).to match %r{^https://example.com/idp2/slo\?SAMLResponse=}
          allow(SAML2::Bindings::HTTPRedirect).to receive(:decode).and_call_original
          message, = SAML2::Bindings::HTTPRedirect.decode(response.location)
          expect(message).to be_a(SAML2::LogoutResponse)
          expect(message.status).not_to be_a_success
          expect(message.status.message).to eql ["No current session"]
        end

        it "redirects an error response to idp if a different user is logged in" do
          user = User.create!
          user_session(user)
          logout_request = SAML2::LogoutRequest.new
          logout_request.issuer = SAML2::NameID.new(@aac2.idp_entity_id)
          logout_request.name_id = SAML2::NameID.new("bogus user")
          expect(SAML2::Bindings::HTTPRedirect).to receive(:decode).and_return(logout_request)

          controller.request.env["canvas.domain_root_account"] = @account
          get :destroy, params: { SAMLRequest: "foo" }

          expect(response).to be_redirect
          expect(response.location).to match %r{^https://example.com/idp2/slo\?SAMLResponse=}
          allow(SAML2::Bindings::HTTPRedirect).to receive(:decode).and_call_original
          message, = SAML2::Bindings::HTTPRedirect.decode(response.location)
          expect(message).to be_a(SAML2::LogoutResponse)
          expect(message.status).not_to be_a_success
          expect(message.status.message).to eql ["NameID does not match current session"]
        end

        it "redirects a response to idp on logout with a SAMLRequest parameter" do
          user = User.create!
          user_session(user)
          session[:name_id] = "real_user"
          expect(controller).to receive(:logout_current_user)
          logout_request = SAML2::LogoutRequest.new
          logout_request.issuer = SAML2::NameID.new(@aac2.idp_entity_id)
          logout_request.name_id = SAML2::NameID.new("real_user")
          expect(SAML2::Bindings::HTTPRedirect).to receive(:decode).and_return(logout_request)

          controller.request.env["canvas.domain_root_account"] = @account
          get :destroy, params: { SAMLRequest: "foo" }

          expect(response).to be_redirect
          expect(response.location).to match %r{^https://example.com/idp2/slo\?SAMLResponse=}
          allow(SAML2::Bindings::HTTPRedirect).to receive(:decode).and_call_original
          message, = SAML2::Bindings::HTTPRedirect.decode(response.location)
          expect(message).to be_a(SAML2::LogoutResponse)
          expect(message.status).to be_a_success
        end

        it "is a bad request if the request can't be validated against the schema" do
          logout_request = SAML2::LogoutRequest.new
          logout_request.issuer = SAML2::NameID.new(@aac2.idp_entity_id)
          allow(logout_request).to receive(:valid_schema?).and_return(false)
          expect(SAML2::Bindings::HTTPRedirect).to receive(:decode).and_return(logout_request)

          controller.request.env["canvas.domain_root_account"] = @account
          get :destroy, params: { SAMLRequest: "foo" }

          expect(response).to have_http_status :bad_request
          expect(response.body).to eql "Invalid SAML message"
        end

        it "can optionally ignore schema validation" do
          logout_request = SAML2::LogoutRequest.new
          logout_request.issuer = SAML2::NameID.new(@aac2.idp_entity_id)
          allow(logout_request).to receive(:valid_schema?).and_return(false)
          @aac2.settings["ignore_slo_schema_errors"] = true
          @aac2.save!
          expect(SAML2::Bindings::HTTPRedirect).to receive(:decode).and_return(logout_request)

          controller.request.env["canvas.domain_root_account"] = @account
          get :destroy, params: { SAMLRequest: "foo" }

          expect(response).to be_redirect
        end

        it "is a bad request if there's no destination to send the request to" do
          expect(controller).to_not receive(:logout_current_user)
          @aac3 = @account.authentication_providers.build(auth_type: "saml")
          @aac3.idp_entity_id = "https://example.com/idp3"
          @aac3.log_in_url = "https://example.com/idp3/sso"
          @aac3.log_out_url = nil
          @aac3.save!
          logout_request = SAML2::LogoutRequest.new
          logout_request.issuer = SAML2::NameID.new(@aac3.idp_entity_id)
          expect(SAML2::Bindings::HTTPRedirect).to receive(:decode).and_return(logout_request)
          get :destroy, params: { SAMLRequest: "foo" }
          expect(response).to have_http_status :bad_request
        end

        it "returns bad request if SAMLRequest parameter doesn't match an AAC" do
          logout_request = SAML2::LogoutRequest.new
          logout_request.issuer = SAML2::NameID.new("hahahahahahaha")
          expect(SAML2::Bindings::HTTPRedirect).to receive(:decode).and_return(logout_request)

          controller.request.env["canvas.domain_root_account"] = @account
          get :destroy, params: { SAMLRequest: "foo" }
          expect(response).to have_http_status :bad_request
        end
      end
    end
  end

  describe "#destroy" do
    let(:certificates) { ["MIIFnzCCBIegAwIBAgIQItX5wssh0ecd46K65PkSNDANBgkqhkiG9w0BAQsFADCBkDELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEaMBgGA1UEChMRQ09NT0RPIENBIExpbWl0ZWQxNjA0BgNVBAMTLUNPTU9ETyBSU0EgRG9tYWluIFZhbGlkYXRpb24gU2VjdXJlIFNlcnZlciBDQTAeFw0xNjA5MDgwMDAwMDBaFw0xOTEwMjUyMzU5NTlaMIGeMSEwHwYDVQQLExhEb21haW4gQ29udHJvbCBWYWxpZGF0ZWQxSTBHBgNVBAsTQElzc3VlZCB0aHJvdWdoIEl2eSBUZWNoIENvbW11bml0eSBDb2xsZWdlIG9mIEluZGlhbmEgRS1QS0kgTWFuYWcxEzARBgNVBAsTCkNPTU9ETyBTU0wxGTAXBgNVBAMTEGFkZnMuaXZ5dGVjaC5lZHUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC58zHz7VsV9S2XZMRjgqiWxBZ6M9y6/3zkrbObJ9hZqO7giCoonNDuELUiNt8pBqF8aHef8qbDOecBBXkz8rPAJL1S6lzvbxHIBuvEy+xOpVdUNMoyOaAYHOI5T6ueL1Q4iGMKfnWuXSvVTyB+9wAF/aWVFSoz+alUOiQtqTYyfgIKzHIAmFX7/SjFA9UjKVtqatcvzWsSWZHL4imeTmPosXXjmJVZnl+jaeFsnmW59o66sdGR+NYkhsBcVRnuP3MdxVgr5xSJMN+/BgZwCncX+4LJq5664eeQcJM5Km9kbQ/jMFhYy765ejszcL0vWe/fS7tdXQCfoKjRZ5LzNEb3AgMBAAGjggHjMIIB3zAfBgNVHSMEGDAWgBSQr2o6lFoL2JDqElZz30O0Oija5zAdBgNVHQ4EFgQUdFr6SnHaXUqLAEdOL9qrTJS/3AYwDgYDVR0PAQH/BAQDAgWgMAwGA1UdEwEB/wQCMAAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCME8GA1UdIARIMEYwOgYLKwYBBAGyMQECAgcwKzApBggrBgEFBQcCARYdaHR0cHM6Ly9zZWN1cmUuY29tb2RvLmNvbS9DUFMwCAYGZ4EMAQIBMFQGA1UdHwRNMEswSaBHoEWGQ2h0dHA6Ly9jcmwuY29tb2RvY2EuY29tL0NPTU9ET1JTQURvbWFpblZhbGlkYXRpb25TZWN1cmVTZXJ2ZXJDQS5jcmwwgYUGCCsGAQUFBwEBBHkwdzBPBggrBgEFBQcwAoZDaHR0cDovL2NydC5jb21vZG9jYS5jb20vQ09NT0RPUlNBRG9tYWluVmFsaWRhdGlvblNlY3VyZVNlcnZlckNBLmNydDAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuY29tb2RvY2EuY29tMDEGA1UdEQQqMCiCEGFkZnMuaXZ5dGVjaC5lZHWCFHd3dy5hZGZzLml2eXRlY2guZWR1MA0GCSqGSIb3DQEBCwUAA4IBAQA0dXP0leDcdrr/iKk4nDSCofllPAWE8LE3mD9Yb9K+/oVymxpqNIVJesDPLtf1HqWk6S6eafcYvfzl9aTMcvwEkL27g2l9UQuICkQgqSEY5qTsK//u/2S98JqXep2oRyvxo3UHX+3Ouc3i49hQ0v05Faoeap/ZT3JEsMV2Go9UKRJbYBG9Nqq/CDBuTgyopKJ7fvCtsGxwsvlUAz/NMuNoUphPQ2S+O/SjabjR4XsAGU78Hji2tqJyvPyKPanxc0ioDdnL5lvrk4uZ/6Dy159C5FOFeLU2ZfiNLXRR85KFfhtX954qvX6jmM7CPmcidhzEnZV8fQv9G6XYPfrNL7bh"] }

    it "returns bad request if SAML is not configured for account" do
      logout_response = SAML2::LogoutResponse.new
      logout_response.issuer = SAML2::NameID.new("entity")
      expect(SAML2::Bindings::HTTPRedirect).to receive(:decode).and_return(logout_response)

      expect(controller).not_to receive(:logout_user_action)
      controller.request.env["canvas.domain_root_account"] = @account
      get :destroy, params: { SAMLResponse: "foo", RelayState: "/courses" }
      expect(response).to have_http_status :bad_request
    end

    it "renders an error if the IdP fails the request" do
      Account.default.authentication_providers.create!(auth_type: "saml",
                                                       idp_entity_id: "http://adfs.ryana.local/adfs/services/trust")
      get :destroy,
          params: { SAMLResponse: <<~BASE64.delete("\n")
            fZLBboMwDIZfBeUOIRQojSjS1F4qdZe26mGXKSSmQ6IJi5Npe/sF0A6Vpp7iWP7j359To7gPIz+am/H
            uBDgajRAd9lvynrFCdmm1ioG1Ks6rTRpvKiXidbtismrbTIEk0RUs9kZvSZakJDogejhodEK7kEpZGa
            d5nJWXjPG05Pk6yTerNxLtAV2vhZuVH86NyCm1P0KLpA9q66XzFhJp7nQwt17TyeYUBpck2k0mpwbea
            m4E9si1uANyJ/n55fXIgxculyLuNY4g+64HFfzpvxkvZktk1ZVMMdaWKwVtCkURTiZLpYo8S/NCyIJl
            Xb6e5vy+Dxr5TOt539EaZ6QZSFPPNOwifS4SiGAnGqSZaAQYQnWYLEQGI8UwJ2io+uolIA2I0NV06dD
            UyxbPTjiPj7edURBdxeDhuQOcq/kJPn3YDVgS0aamj+/S/z5L8ws=
          BASE64
      }
      expect(response).to redirect_to(login_url)
      expect(flash[:delegated_message]).not_to be_nil
    end

    it "returns bad request if the AAC has a certificate, but the LogoutRequest is not signed" do
      account = account_with_saml
      aac = account.authentication_providers.first
      aac.settings[:signing_certificates] = certificates
      aac.save!

      logout_request = SAML2::LogoutRequest.new
      logout_request.issuer = SAML2::NameID.new(aac.idp_entity_id)
      logout_request.name_id = SAML2::NameID.new("cody")
      logout_request.destination = ""
      url = SAML2::Bindings::HTTPRedirect.encode(logout_request)
      saml_request = URI.decode_www_form(URI.parse(url).query).first.last

      controller.request.env["canvas.domain_root_account"] = account
      expect(Canvas::Errors).to receive(:capture_exception) do |category, error, level|
        expect(category).to eq(:saml)
        expect(error.class).to eq(SAML2::UnsignedMessage)
        expect(level).to eq(:warn)
      end
      get :destroy, params: { SAMLRequest: saml_request }

      expect(response).to have_http_status :bad_request
    end

    it "accepts an HTTP-POST message" do
      account = account_with_saml
      aac = account.authentication_providers.first
      aac.settings[:signing_certificates] = certificates
      aac.log_out_url = "https://idp.school.edu/logout"
      aac.save!

      logout_request = SAML2::LogoutRequest.new
      logout_request.issuer = SAML2::NameID.new(aac.idp_entity_id)
      logout_request.name_id = SAML2::NameID.new("cody")
      logout_request.destination = ""
      post_params = SAML2::Bindings::HTTP_POST.encode(logout_request)

      controller.request.env["canvas.domain_root_account"] = account
      expect_any_instance_of(SAML2::LogoutRequest).to receive(:signed?).and_return(true)
      expect_any_instance_of(SAML2::LogoutRequest).to receive(:validate_signature).and_return([])
      post :destroy, params: post_params

      expect(response).to have_http_status :found
      expect(response.location).to match(%r{^https://idp.school.edu/logout})
    end
  end

  context "login attributes" do
    before :once do
      @unique_id = "foo"

      @account = account_with_saml
      @user = user_with_pseudonym({ active_all: true, username: @unique_id })
      @pseudonym.account = @account
      @pseudonym.save!

      @aac = @account.authentication_providers.first
    end

    it "uses the eduPersonPrincipalName attribute with the domain stripped" do
      @aac.login_attribute = "eduPersonPrincipalName_stripped"
      @aac.save

      response = SAML2::Response.new
      response.issuer = SAML2::NameID.new("saml_entity")
      response.assertions << (assertion = SAML2::Assertion.new)
      assertion.subject = SAML2::Subject.new
      assertion.subject.name_id = SAML2::NameID.new(@unique_id)
      assertion.statements << SAML2::AttributeStatement.new([SAML2::Attribute.create("eduPersonPrincipalName", "#{@unique_id}@example.edu")])
      allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
        [response, "/courses"]
      )
      allow_any_instance_of(SAML2::Entity).to receive(:valid_response?)

      controller.request.env["canvas.domain_root_account"] = @account
      post :create, params: { SAMLResponse: "foo", RelayState: "/courses" }
      expect(response).to redirect_to(courses_url)
      expect(session[:saml_unique_id]).to eq @unique_id
    end

    it "uses the NameID if no login attribute is specified" do
      @aac.login_attribute = nil
      @aac.save

      response = SAML2::Response.new
      response.issuer = SAML2::NameID.new("saml_entity")
      response.assertions << (assertion = SAML2::Assertion.new)
      assertion.subject = SAML2::Subject.new
      assertion.subject.name_id = SAML2::NameID.new(@unique_id)
      allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
        [response, "/courses"]
      )
      allow_any_instance_of(SAML2::Entity).to receive(:valid_response?)

      controller.request.env["canvas.domain_root_account"] = @account
      post :create, params: { SAMLResponse: "foo", RelayState: "/courses" }
      expect(response).to redirect_to(courses_url)
      expect(session[:saml_unique_id]).to eq @unique_id
    end
  end

  it "uses the eppn saml attribute if configured" do
    unique_id = "foo"

    account = account_with_saml
    @aac = @account.authentication_providers.first
    @aac.login_attribute = "eduPersonPrincipalName_stripped"
    @aac.save

    user_with_pseudonym({ active_all: true, username: unique_id })
    @pseudonym.account = account
    @pseudonym.save!

    response = SAML2::Response.new
    response.issuer = SAML2::NameID.new("saml_entity")
    response.assertions << (assertion = SAML2::Assertion.new)
    assertion.subject = SAML2::Subject.new
    assertion.subject.name_id = SAML2::NameID.new(unique_id)
    assertion.statements << SAML2::AttributeStatement.new([SAML2::Attribute.create("eduPersonPrincipalName", "#{unique_id}@example.edu")])
    allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
      [response, "/courses"]
    )
    allow_any_instance_of(SAML2::Entity).to receive(:valid_response?)

    controller.request.env["canvas.domain_root_account"] = account
    post :create, params: { SAMLResponse: "foo", RelayState: "/courses" }
    expect(response).to redirect_to(courses_url)
    expect(session[:saml_unique_id]).to eq unique_id
  end

  it "redirects to RelayState relative urls" do
    unique_id = "foo@example.com"

    account = account_with_saml
    user_with_pseudonym({ active_all: true, username: unique_id })
    @pseudonym.account = account
    @pseudonym.save!

    response = SAML2::Response.new
    response.issuer = SAML2::NameID.new("saml_entity")
    response.assertions << (assertion = SAML2::Assertion.new)
    assertion.subject = SAML2::Subject.new
    assertion.subject.name_id = SAML2::NameID.new(unique_id)
    allow(SAML2::Bindings::HTTP_POST).to receive(:decode).and_return(
      [response, "/courses"]
    )
    allow_any_instance_of(SAML2::Entity).to receive(:valid_response?)

    controller.request.env["canvas.domain_root_account"] = account
    post :create, params: { SAMLResponse: "foo", RelayState: "/courses" }
    expect(response).to redirect_to(courses_url)
    expect(session[:saml_unique_id]).to eq unique_id
  end

  it "decodes an actual saml response" do
    unique_id = "student@example.edu"

    account_with_saml

    @account.settings[:allow_expired_saml_certificate] = true
    @account.settings[:saml_entity_id] = "http://shard1.localdomain/saml2"
    @account.save!
    @aac = @account.authentication_providers.first
    @aac.idp_entity_id = "http://phpsite/simplesaml/saml2/idp/metadata.php"
    @aac.login_attribute = "eduPersonPrincipalName"
    @aac.certificate_fingerprint = "AF:E7:1C:28:EF:74:0B:C8:74:25:BE:13:A2:26:3D:37:97:1D:A1:F9"
    @aac.save

    user_with_pseudonym(active_all: true, username: unique_id)
    @pseudonym.account = @account
    @pseudonym.save!

    controller.request.env["canvas.domain_root_account"] = @account
    Timecop.freeze(Time.zone.parse("2012-08-03T20:07:15Z")) do
      Auditors::ActiveRecord::Partitioner.process
      post :create, params: { SAMLResponse: saml_response_fixture }
      expect(response).to redirect_to(dashboard_url(login_success: 1))
      expect(session[:saml_unique_id]).to eq unique_id
    end
  end

  it "decodes an actual saml response via SAML2" do
    unique_id = "student@example.edu"

    account_with_saml

    @account.settings[:allow_expired_saml_certificate] = true
    @account.settings[:saml_entity_id] = "http://shard1.localdomain/saml2"
    @account.settings[:process_saml_responses_with_saml2] = true
    @account.save!
    @aac = @account.authentication_providers.first
    @aac.idp_entity_id = "http://phpsite/simplesaml/saml2/idp/metadata.php"
    @aac.login_attribute = "eduPersonPrincipalName"
    @aac.certificate_fingerprint = "AF:E7:1C:28:EF:74:0B:C8:74:25:BE:13:A2:26:3D:37:97:1D:A1:F9"
    @aac.save

    user_with_pseudonym(active_all: true, username: unique_id)
    @pseudonym.account = @account
    @pseudonym.save!

    controller.request.env["canvas.domain_root_account"] = @account
    Timecop.freeze(Time.zone.parse("2012-08-03T20:07:15Z")) do
      Auditors::ActiveRecord::Partitioner.process
      post :create, params: { SAMLResponse: saml_response_fixture }
      expect(response).to redirect_to(dashboard_url(login_success: 1))
      expect(session[:saml_unique_id]).to eq unique_id
    end
  end

  describe "#metadata" do
    it "does not persist the entity id if no saml provider exists" do
      get :metadata
      expect(Account.default.settings).not_to have_key(:saml_entity_id)
    end

    it "does persist the entity id if a saml provider exists" do
      Account.default.authentication_providers.create!(auth_type: "saml")
      expect(Account.default.reload.settings).not_to have_key(:saml_entity_id)
      get :metadata
      expect(Account.default.reload.settings[:saml_entity_id]).not_to be_blank
    end
  end
end
