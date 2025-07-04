/*
 * Copyright (C) 2017 - present Instructure, Inc.
 *
 * This file is part of Canvas.
 *
 * Canvas is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Affero General Public License as published by the Free
 * Software Foundation, version 3 of the License.
 *
 * Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Affero General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import {useScope as createI18nScope} from '@canvas/i18n'
import React from 'react'
import useDateTimeFormat from '@canvas/use-date-time-format-hook'

import {View} from '@instructure/ui-view'
import {Text} from '@instructure/ui-text'
import {ScreenReaderContent} from '@instructure/ui-a11y-content'
import {Menu} from '@instructure/ui-menu'
import {IconReplyLine, IconLockLine, IconUnlockLine, IconTrashLine} from '@instructure/ui-icons'

import AnnouncementModel from '@canvas/discussions/backbone/models/Announcement'
import SectionsTooltip from '@canvas/sections-tooltip'
import CourseItemRow from './CourseItemRow'
import UnreadBadge from '@canvas/unread-badge'
import {makeTimestamp} from '@canvas/datetime/react/date-utils'

const I18n = createI18nScope('shared_components')

interface Author {
  id: string
  name: string
  display_name?: string
  avatar_image_url?: string | null
  html_url: string
}

interface Section {
  id: string
  name: string
}

interface Announcement {
  id: string
  position: number
  published: boolean
  title: string
  message: string
  posted_at?: string
  delayed_post_at?: string
  author: Author
  read_state?: 'read' | 'unread'
  discussion_subentry_count: number
  unread_count: number
  locked: boolean
  html_url: string
  permissions?: {
    reply?: boolean
  }
  user_count?: number
  sections?: Section[]
}

interface MasterCourseData {
  canManageCourse?: boolean
  canAutoPublishCourses?: boolean
  isChildCourse?: boolean
  isMasterCourse?: boolean
  accountId?: string | number
  masterCourse?: {
    id: string | number
  }
}

interface AnnouncementRowProps {
  announcement: Announcement
  canManage?: boolean
  canDelete?: boolean
  masterCourseData?: MasterCourseData | null
  rowRef?: (ref: any) => void
  onSelectedChanged?: (selected: boolean, id: string) => void
  onManageMenuSelect?: (event: any, value: any) => void
  canHaveSections?: boolean
  announcementsLocked?: boolean
}

export default function AnnouncementRow({
  announcement,
  canManage = false,
  canDelete = false,
  masterCourseData = null,
  rowRef = () => {},
  onSelectedChanged = () => {},
  onManageMenuSelect = () => {},
  canHaveSections = false,
  announcementsLocked = false,
}: AnnouncementRowProps) {
  const dateFormatter = useDateTimeFormat('time.formats.medium')
  const timestamp = makeTimestamp(
    {
      delayed_post_at: announcement.delayed_post_at,
      posted_at: announcement.posted_at,
    },
    I18n.t('Delayed until:'),
    I18n.t('Posted on:'),
  )
  const readCount =
    announcement.discussion_subentry_count > 0 ? (
      <UnreadBadge
        unreadCount={announcement.unread_count}
        unreadLabel={I18n.t('%{count} unread replies', {count: announcement.unread_count})}
        totalCount={announcement.discussion_subentry_count}
        totalLabel={I18n.t('%{count} replies', {count: announcement.discussion_subentry_count})}
      />
    ) : null

  const sectionsToolTip = canHaveSections ? (
    <SectionsTooltip totalUserCount={announcement.user_count} sections={announcement.sections} />
  ) : null

  const replyButton = announcement?.permissions?.reply ? (
    <View display="block" margin="x-small 0 0" data-testid="announcement-reply">
      <Text color="brand">
        <IconReplyLine /> {I18n.t('Reply')}
      </Text>
    </View>
  ) : null

  const renderMenuList = () => {
    const menuList = []
    if (canDelete) {
      menuList.push(
        <Menu.Item
          key="delete"
          value={{action: 'delete', id: announcement.id} as any}
          id="delete-announcement-menu-option"
        >
          <span aria-hidden="true">
            <IconTrashLine />
            &nbsp;&nbsp;{I18n.t('Delete')}
          </span>
          <ScreenReaderContent>
            {I18n.t('Delete announcement %{title}', {title: announcement.title})}
          </ScreenReaderContent>
        </Menu.Item>,
      )
    }
    if (!announcementsLocked) {
      menuList.push(
        <Menu.Item
          key="lock"
          value={{action: 'lock', id: announcement.id, lock: !announcement.locked} as any}
          id="lock-announcement-menu-option"
          data-action-state={announcement.locked ? 'allowCommentsButton' : 'disallowCommentsButton'}
        >
          {announcement.locked ? (
            <span aria-hidden="true">
              <IconUnlockLine />
              &nbsp;&nbsp;{I18n.t('Allow Comments')}
            </span>
          ) : (
            <span aria-hidden="true">
              <IconLockLine />
              &nbsp;&nbsp;{I18n.t('Disallow Comments')}
            </span>
          )}
          <ScreenReaderContent>
            {announcement.locked
              ? I18n.t('Allow comments for %{title}', {title: announcement.title})
              : I18n.t('Disallow comments for %{title}', {title: announcement.title})}
          </ScreenReaderContent>
        </Menu.Item>,
      )
    }
    return menuList
  }

  // necessary because announcements return html from RCE
  const contentWrapper = document.createElement('span')
  contentWrapper.innerHTML = announcement.message
  const textContent = contentWrapper.textContent?.trim() || ''

  return (
    <CourseItemRow
      title={announcement.title}
      body={
        textContent ? (
          <div className="ic-announcement-row__content user_content">{textContent}</div>
        ) : null
      }
      sectionToolTip={sectionsToolTip}
      replyButton={replyButton}
      ref={rowRef}
      className="ic-announcement-row"
      selectable={canManage || canDelete}
      showAvatar={true}
      id={announcement.id}
      isRead={announcement.read_state === 'read'}
      author={announcement.author}
      itemUrl={announcement.html_url}
      onSelectedChanged={onSelectedChanged}
      masterCourse={{
        courseData: masterCourseData || {},
        getLockOptions: () => ({
          model: new AnnouncementModel(announcement),
          unlockedText: I18n.t('%{title} is unlocked. Click to lock.', {title: announcement.title}),
          lockedText: I18n.t('%{title} is locked. Click to unlock', {title: announcement.title}),
          course_id: masterCourseData?.masterCourse?.id,
          content_id: announcement.id,
          content_type: 'discussion_topic',
        }),
      }}
      metaContent={
        <div>
          <span className="ic-item-row__meta-content-heading">
            <Text size="small" as="p">
              {timestamp.title}
            </Text>
          </span>
          <span className="ic-item-row__meta-content-timestamp">
            <Text color="secondary" size="small" as="p">
              {dateFormatter(timestamp.date)}
            </Text>
          </span>
        </div>
      }
      actionsContent={readCount}
      showManageMenu={canManage || canDelete}
      onManageMenuSelect={onManageMenuSelect}
      manageMenuOptions={renderMenuList}
      hasReadBadge={true}
    />
  )
}
